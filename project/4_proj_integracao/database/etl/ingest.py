import gc
import json
import logging
import sys
from datetime import datetime
from pathlib import Path

import pandas as pd
import pyodbc
from sqlalchemy import create_engine, text
from tqdm import tqdm

# ============================================================
# CONFIGURACAO
# ============================================================

DB_CONNECTION = (
    "mssql+pyodbc://localhost/F1_DB?driver=ODBC+Driver+17+for+SQL+Server"
    "&trusted_connection=yes"
)
DATA_PATH = Path(__file__).resolve().parents[3] / "_data"

CSV_ENCODING = "utf-8"
CSV_NA_VALUES = ["\\N", ""]

# Ordem de carga dos CSVs respeitando dependencias de FK
CSV_LOAD_ORDER = [
    "seasons",
    "circuits",
    "constructors",
    "drivers",
    "status",
    "races",
    "results",
    "sprint_results",
    "lap_times",
    "pit_stops",
    "qualifying",
    "constructor_results",
    "constructor_standings",
    "driver_standings",
    "safety_cars",
    "red_flags",
    "fatal_accidents_drivers",
    "fatal_accidents_marshalls",
]

# CSVs cujo header tem espacos nos nomes das colunas
CSV_COLUMN_RENAME = {
    "fatal_accidents_drivers": {"Date Of Accident": "DateOfAccident"},
    "fatal_accidents_marshalls": {"Date Of Accident": "DateOfAccident"},
}

# Tabelas com chave primaria composta - usadas no drop_duplicates(subset=...)
PK_SUBSET = {
    "lap_times": ["raceId", "driverId", "lap"],
    "pit_stops": ["raceId", "driverId", "stop"],
}

# ============================================================
# LOGGING
# ============================================================

LOG_DIR = Path(__file__).resolve().parent / "logs"
LOG_DIR.mkdir(parents=True, exist_ok=True)

FORMAT = "%(asctime)s | %(levelname)-7s | %(message)s"
DATEFMT = "%H:%M:%S"

console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
console_handler.setFormatter(logging.Formatter(FORMAT, DATEFMT))

log_timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
file_handler = logging.FileHandler(
    LOG_DIR / f"ingest_{log_timestamp}.txt",
    encoding="utf-8",
)
file_handler.setLevel(logging.INFO)
file_handler.setFormatter(logging.Formatter(FORMAT, DATEFMT))

logging.basicConfig(
    level=logging.INFO,
    format=FORMAT,
    datefmt=DATEFMT,
    handlers=[console_handler, file_handler],
)
log = logging.getLogger(__name__)

# ============================================================
# DATABASE HELPERS
# ============================================================

def get_engine():
    return create_engine(DB_CONNECTION, fast_executemany=False)


# ============================================================
# CONVERSORES
# ============================================================

def _to_int(v):
    if v is None or v == "None" or (isinstance(v, str) and v.strip().lower() == "none"):
        return None
    try:
        return int(v)
    except (ValueError, TypeError):
        return None


def _to_float(v):
    if v is None or v == "None" or (isinstance(v, str) and v.strip().lower() == "none"):
        return None
    try:
        return float(v)
    except (ValueError, TypeError):
        return None


def _to_bool(v):
    if v is None or v == "None" or (isinstance(v, str) and v.strip().lower() == "none"):
        return None
    try:
        return bool(v)
    except (ValueError, TypeError):
        return None


def _to_none(v):
    if v is None or v == "None" or (isinstance(v, str) and v.strip().lower() == "none"):
        return None
    return v


def table_exists(conn, table_name):
    result = conn.execute(
        text("SELECT COUNT(*) FROM sys.tables WHERE name = :t"),
        {"t": table_name},
    )
    return result.scalar() > 0


def truncate_table(conn, table_name):
    conn.execute(text(f"TRUNCATE TABLE {table_name}"))


# ============================================================
# CSV INGESTION
# ============================================================

CSV_FILES = {
    "seasons": "seasons.csv",
    "circuits": "circuits.csv",
    "constructors": "constructors.csv",
    "drivers": "drivers.csv",
    "status": "status.csv",
    "races": "races.csv",
    "results": "results.csv",
    "sprint_results": "sprint_results.csv",
    "lap_times": "lap_times.csv",
    "pit_stops": "pit_stops.csv",
    "qualifying": "qualifying.csv",
    "constructor_results": "constructor_results.csv",
    "constructor_standings": "constructor_standings.csv",
    "driver_standings": "driver_standings.csv",
    "safety_cars": "safety_cars.csv",
    "red_flags": "red_flags.csv",
    "fatal_accidents_drivers": "fatal_accidents_drivers.csv",
    "fatal_accidents_marshalls": "fatal_accidents_marshalls.csv",
}


def ingest_csvs(engine):
    log.info("=== INGESTAO CSV ===")

    for table_name in tqdm(CSV_LOAD_ORDER, desc="CSVs", unit="tabela"):
        filename = CSV_FILES[table_name]
        filepath = DATA_PATH / filename

        if not filepath.exists():
            log.warning("Ficheiro nao encontrado: %s", filepath)
            continue

        rename_map = CSV_COLUMN_RENAME.get(table_name, {})

        # usar utf-8-sig para remover BOM (existe no fatal_accidents_drivers)
        df = pd.read_csv(
            filepath,
            encoding="utf-8-sig",
            na_values=CSV_NA_VALUES,
            dtype_backend="numpy_nullable",
        )

        if rename_map:
            df = df.rename(columns=rename_map)

        # tratar campos de tempo que podem vir com espacos extras
        for col in df.select_dtypes(include="object").columns:
            df[col] = df[col].str.strip()

        # converter tipos para compatibilidade com SQL Server via fast_executemany
        # (colunas string para TIME / DECIMAL causam erro de truncatura ou cast)
        if table_name == "pit_stops":
            df["time"] = pd.to_datetime(df["time"], format="%H:%M:%S", errors="coerce").dt.time
            df["duration"] = pd.to_numeric(df["duration"], errors="coerce")

        # o CSV usa N/A / vazio para campos opcionais, mas ha colunas NOT NULL
        if table_name == "fatal_accidents_drivers":
            df["Event"] = df["Event"].fillna("N/A")
            df["Age"] = df["Age"].fillna(0).astype("int64")

        # remover duplicados (ex: lap_times.csv tem ~4k linhas duplicadas)
        before = len(df)
        subset = PK_SUBSET.get(table_name)
        df = df.drop_duplicates(subset=subset)
        if len(df) < before:
            log.info("  Duplicados removidos: %d", before - len(df))

        with engine.begin() as conn:
            if not table_exists(conn, table_name):
                log.error("Tabela %s nao existe na base de dados!", table_name)
                continue

            truncate_table(conn, table_name)

            rows = len(df)
            if rows == 0:
                log.warning("CSV vazio: %s", filename)
                continue

            df.to_sql(
                table_name,
                conn,
                if_exists="append",
                index=False,
                chunksize=3000,
            )

        log.info("  %s -> %s (%d linhas)", filename, table_name, rows)
        engine.dispose()
        gc.collect()


# ============================================================
# VIRTUAL SAFETY CAR (JSON unico, fora do loop de pastas)
# ============================================================

def ingest_virtual_safety_car(engine):
    filepath = DATA_PATH / "virtual_safety_car_estimates.json"
    if not filepath.exists():
        log.warning("Ficheiro VSC nao encontrado: %s", filepath)
        return

    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)

    rows = []
    for race_name, laps in data.items():
        for lap_number in laps:
            rows.append({"race_name": race_name, "lap_number": lap_number})

    if not rows:
        log.info("  virtual_safety_car: sem dados")
        return

    df = pd.DataFrame(rows)
    with engine.begin() as conn:
        if table_exists(conn, "virtual_safety_car"):
            df.to_sql(
                "virtual_safety_car",
                conn,
                if_exists="append",
                index=False,
                chunksize=5000,
            )
    log.info("  virtual_safety_car -> %d linhas", len(df))


# ============================================================
# SESSION / JSON INGESTION  (pasta a pasta)
# ============================================================

def get_or_create_session(conn, ano, gp, sessao):
    """Retorna session_id. Se ja existir, retorna; se nao, cria."""
    result = conn.execute(
        text("SELECT session_id FROM sessions WHERE ano = :a AND gp = :g AND sessao = :s"),
        {"a": ano, "g": gp, "s": sessao},
    )
    row = result.fetchone()
    if row:
        return row[0]

    result = conn.execute(
        text("INSERT INTO sessions (ano, gp, sessao) OUTPUT INSERTED.session_id VALUES (:a, :g, :s)"),
        {"a": ano, "g": gp, "s": sessao},
    )
    return result.fetchone()[0]


def ingest_session_folder(engine, ano, gp_name, sessao):
    """Processa uma pasta de sessao (apenas Race) e carrega todos os JSONs."""
    folder = DATA_PATH / str(ano) / gp_name / sessao
    if not folder.is_dir():
        return

    with engine.begin() as conn:
        session_id = get_or_create_session(conn, ano, gp_name, sessao)

    # --- weather.json ---
    ingest_weather(engine, session_id, folder)

    # --- drivers.json ---
    ingest_session_drivers(engine, session_id, folder)

    # --- corners.json ---
    ingest_session_corners(engine, session_id, folder)

    # --- rcm.json ---
    ingest_rcm(engine, session_id, folder)

    # --- pasta de cada piloto ---
    for driver_folder in sorted(folder.iterdir()):
        if not driver_folder.is_dir():
            continue
        driver_code = driver_folder.name

        # driver_laptimes.json
        ingest_driver_laptimes(engine, session_id, driver_code, driver_folder)

        # telemetry: {n}_tel.json
        ingest_telemetry(engine, session_id, driver_code, driver_folder)


def ingest_weather(engine, session_id, folder):
    filepath = folder / "weather.json"
    if not filepath.exists():
        return
    with open(filepath, "r", encoding="utf-8") as f:
        raw = json.load(f)

    keys = raw.get("wT", [])
    if not keys:
        return

    rows = []
    for i in range(len(keys)):
        row = {
            "session_id": session_id,
            "reading_idx": i,
            "timestamp_s": raw["wT"][i] if i < len(raw.get("wT", [])) else None,
            "track_temp": raw.get("wTT", [None] * len(keys))[i],
            "air_temp": raw.get("wAT", [None] * len(keys))[i],
            "humidity": raw.get("wHum", [None] * len(keys))[i],
            "wind_speed": raw.get("wWindSpeed", [None] * len(keys))[i],
            "wind_dir": raw.get("wWindDir", [None] * len(keys))[i],
        }
        rows.append(row)

    if not rows:
        return

    df = pd.DataFrame(rows)
    with engine.begin() as conn:
        df.to_sql("weather", conn, if_exists="append", index=False, chunksize=5000)
    log.info("  weather (%d registos)", len(df))


def ingest_session_drivers(engine, session_id, folder):
    filepath = folder / "drivers.json"
    if not filepath.exists():
        return
    with open(filepath, "r", encoding="utf-8") as f:
        raw = json.load(f)

    drivers_list = raw.get("drivers", [])
    if not drivers_list:
        return

    rows = [
        {
            "session_id": session_id,
            "driver_code": d.get("driver"),
            "team": d.get("team"),
            "driver_number": int(d.get("dn", 0)),
            "first_name": d.get("fn") or "Unknown",
            "last_name": d.get("ln") or "Unknown",
        }
        for d in drivers_list
    ]

    df = pd.DataFrame(rows)
    with engine.begin() as conn:
        df.to_sql("session_drivers", conn, if_exists="append", index=False, chunksize=1000)
    log.info("  session_drivers (%d registos)", len(df))


def ingest_session_corners(engine, session_id, folder):
    filepath = folder / "corners.json"
    if not filepath.exists():
        return
    with open(filepath, "r", encoding="utf-8") as f:
        raw = json.load(f)

    corners = raw.get("CornerNumber", [])
    if not corners:
        return

    xs = raw.get("X", [])
    ys = raw.get("Y", [])
    distances = raw.get("Distance", [])
    angles = raw.get("Angle", [])
    rotation = raw.get("Rotation")

    rows = []
    for i in range(len(corners)):
        rows.append({
            "session_id": session_id,
            "corner_number": corners[i],
            "x": xs[i] if i < len(xs) else None,
            "y": ys[i] if i < len(ys) else None,
            "distance": distances[i] if i < len(distances) else None,
            "angle": angles[i] if i < len(angles) else None,
            "rotation": rotation if rotation is not None else 0,
        })

    df = pd.DataFrame(rows)
    with engine.begin() as conn:
        df.to_sql("session_corners", conn, if_exists="append", index=False, chunksize=1000)
    log.info("  session_corners (%d registos)", len(df))


def ingest_rcm(engine, session_id, folder):
    filepath = folder / "rcm.json"
    if not filepath.exists():
        return
    with open(filepath, "r", encoding="utf-8") as f:
        raw = json.load(f)

    times = raw.get("time", [])
    if not times:
        return

    rows = [
        {
            "session_id": session_id,
            "timestamp": times[i],
            "category": _to_none(raw.get("cat", [None] * len(times))[i]),
            "flag": _to_none(raw.get("flag", [None] * len(times))[i]),
            "lap": _to_int(raw.get("lap", [None] * len(times))[i]),
            "message": raw.get("msg", [None] * len(times))[i],
            "scope": _to_none(raw.get("scope", [None] * len(times))[i]),
            "sector": _to_int(raw.get("sector", [None] * len(times))[i]),
            "driver_number": _to_int(raw.get("dNum", [None] * len(times))[i]),
        }
        for i in range(len(times))
    ]

    df = pd.DataFrame(rows)
    with engine.begin() as conn:
        df.to_sql("race_control_msgs", conn, if_exists="append", index=False, chunksize=5000)
    log.info("  race_control_msgs (%d registos)", len(df))


def ingest_driver_laptimes(engine, session_id, driver_code, driver_folder):
    filepath = driver_folder / "laptimes.json"
    if not filepath.exists():
        return

    with open(filepath, "r", encoding="utf-8") as f:
        raw = json.load(f)

    laps = raw.get("lap", [])
    if not laps:
        return

    times = raw.get("time", [None] * len(laps))
    compounds = raw.get("compound", [None] * len(laps))
    stints = raw.get("stint", [None] * len(laps))
    s1s = raw.get("s1", [None] * len(laps))
    s2s = raw.get("s2", [None] * len(laps))
    s3s = raw.get("s3", [None] * len(laps))
    positions = raw.get("pos", [None] * len(laps))
    lives = raw.get("life", [None] * len(laps))
    freshs = raw.get("fresh", [None] * len(laps))
    statuses = raw.get("status", [None] * len(laps))
    pouts = raw.get("pout", [None] * len(laps))
    pins = raw.get("pin", [None] * len(laps))
    iaccs = raw.get("iacc", [None] * len(laps))

    rows = [
        {
            "session_id": session_id,
            "driver_code": driver_code,
            "time_s": _to_float(times[i]),
            "lap": laps[i],
            "compound": _to_none(compounds[i]),
            "stint": _to_int(stints[i]),
            "s1": _to_float(s1s[i]),
            "s2": _to_float(s2s[i]),
            "s3": _to_float(s3s[i]),
            "position": _to_int(positions[i]),
            "life": _to_int(lives[i]),
            "fresh": _to_bool(freshs[i]),
            "status": _to_int(statuses[i]),
            "pout": _to_float(pouts[i]),
            "pin": _to_float(pins[i]),
            "iacc": _to_bool(iaccs[i]),
        }
        for i in range(len(laps))
    ]

    df = pd.DataFrame(rows)
    with engine.begin() as conn:
        df.to_sql("driver_laptimes", conn, if_exists="append", index=False, chunksize=5000)


def ingest_telemetry(engine, session_id, driver_code, driver_folder):
    tele_files = sorted(driver_folder.glob("*_tel.json"))
    if not tele_files:
        return

    all_rows = []
    for tel_path in tele_files:
        lap_num = int(tel_path.stem.split("_")[0])
        with open(tel_path, "r", encoding="utf-8") as f:
            raw = json.load(f)

        tel_data = raw.get("tel", {})
        times = tel_data.get("time", [])
        if not times:
            continue

        speeds = tel_data.get("speed", [None] * len(times))
        rpms = tel_data.get("rpm", [None] * len(times))
        gears = tel_data.get("gear", [None] * len(times))
        throttles = tel_data.get("throttle", [None] * len(times))
        brakes = tel_data.get("brake", [None] * len(times))
        drss = tel_data.get("drs", [None] * len(times))
        distances = tel_data.get("distance", [None] * len(times))
        xs = tel_data.get("x", [None] * len(times))
        ys = tel_data.get("y", [None] * len(times))
        zs = tel_data.get("z", [None] * len(times))

        for i in range(len(times)):
            all_rows.append({
                "session_id": session_id,
                "driver_code": driver_code,
                "lap": lap_num,
                "time_s": times[i],
                "speed": _to_float(speeds[i]),
                "rpm": _to_float(rpms[i]),
                "gear": _to_int(gears[i]),
                "throttle": _to_float(throttles[i]),
                "brake": _to_bool(brakes[i]),
                "drs": _to_bool(drss[i]),
                "distance": _to_float(distances[i]),
                "x": _to_float(xs[i]),
                "y": _to_float(ys[i]),
                "z": _to_float(zs[i]),
            })

    if not all_rows:
        return

    df = pd.DataFrame(all_rows)
    with engine.begin() as conn:
        df.to_sql("telemetry", conn, if_exists="append", index=False, chunksize=10000)


# ============================================================
# SCANNER DE PASTAS
# ============================================================

def scan_and_ingest_sessions(engine):
    log.info("=== INGESTAO JSON (pasta a pasta) ===")

    # Descobrir pastas Race em todos os anos
    race_folders = []
    for ano_dir in sorted(DATA_PATH.iterdir()):
        if not ano_dir.is_dir() or not ano_dir.name.isdigit():
            continue
        for gp_dir in sorted(ano_dir.iterdir()):
            if not gp_dir.is_dir():
                continue
            race_dir = gp_dir / "Race"
            if race_dir.is_dir():
                race_folders.append((int(ano_dir.name), gp_dir.name, "Race"))

    if not race_folders:
        log.warning("Nenhuma pasta Race encontrada em %s", DATA_PATH)
        return

    log.info("Encontradas %d sessoes Race", len(race_folders))

    for ano, gp_name, sessao in tqdm(race_folders, desc="Sessoes", unit="sessao"):
        folder = DATA_PATH / str(ano) / gp_name / sessao
        try:
            ingest_session_folder(engine, ano, gp_name, sessao)
        except Exception as e:
            log.error("Erro em %s: %s", folder, e)


# ============================================================
# MAIN
# ============================================================

def main():
    log.info("=" * 60)
    log.info("F1_DB Ingestion Script")
    log.info("Data path: %s", DATA_PATH)
    log.info("=" * 60)

    engine = get_engine()

    # testar conexao
    try:
        with engine.connect() as conn:
            conn.execute(text("SELECT 1"))
    except Exception as e:
        log.error("Erro de conexao a base de dados: %s", e)
        log.error("Verifique a string de conexao: %s", DB_CONNECTION)
        sys.exit(1)

    log.info("Conexao a base de dados OK")

    # 1. CSVs
    ingest_csvs(engine)

    # 2. Virtual Safety Car (JSON unico)
    ingest_virtual_safety_car(engine)

    # 3. JSON session a session
    scan_and_ingest_sessions(engine)

    log.info("=" * 60)
    log.info("Ingestao concluida com sucesso!")
    log.info("=" * 60)


if __name__ == "__main__":
    main()
