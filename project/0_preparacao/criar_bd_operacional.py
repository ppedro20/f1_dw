"""
criar_bd_operacional.py
=======================
Cria a base de dados operacional f1_operacional no SQL Server
e popula-a com os 18 ficheiros CSV originais.

Pré-requisitos:
    pip install pandas sqlalchemy pyodbc

Configuração:
    Ajusta as variáveis SERVER e AUTH_MODE abaixo antes de correr.
"""

import pandas as pd
import sqlalchemy as sa
from sqlalchemy import text
import os

# ─────────────────────────────────────────────
#  CONFIGURAÇÃO — alterar conforme o ambiente
# ─────────────────────────────────────────────
SERVER   = r"localhost"          # ex: localhost, .\SQLEXPRESS, DESKTOP-ABC\SQLEXPRESS
DB_NAME  = "f1_operacional"
DRIVER   = "ODBC Driver 17 for SQL Server"

# Autenticação Windows (trusted connection) — opção mais comum em lab/local
AUTH_MODE = "sql"
# Se precisares de SQL Server Auth, muda para "sql" e preenche:
SQL_USER  = "sa"
SQL_PASS  = "password123"

CSV_DIR  = os.path.dirname(os.path.abspath(__file__))
BATCH_SIZE = 5000  # linhas por batch (útil para tabelas grandes)

# ─────────────────────────────────────────────
#  TIPOS SQL POR TABELA
# ─────────────────────────────────────────────
SQL_TYPES = {
    "circuits": {
        "circuitId":  sa.Integer(),
        "circuitRef": sa.VARCHAR(20),
        "name":       sa.VARCHAR(100),
        "location":   sa.VARCHAR(50),
        "country":    sa.VARCHAR(50),
        "lat":        sa.Numeric(10, 6),
        "lng":        sa.Numeric(10, 6),
        "alt":        sa.Integer(),
        "url":        sa.VARCHAR(200),
    },
    "constructor_results": {
        "constructorResultsId": sa.Integer(),
        "raceId":               sa.Integer(),
        "constructorId":        sa.Integer(),
        "points":               sa.Numeric(6, 2),
        "status":               sa.VARCHAR(5),
    },
    "constructor_standings": {
        "constructorStandingsId": sa.Integer(),
        "raceId":                 sa.Integer(),
        "constructorId":          sa.Integer(),
        "points":                 sa.Numeric(8, 2),
        "position":               sa.Integer(),
        "positionText":           sa.VARCHAR(5),
        "wins":                   sa.Integer(),
    },
    "constructors": {
        "constructorId":  sa.Integer(),
        "constructorRef": sa.VARCHAR(25),
        "name":           sa.VARCHAR(50),
        "nationality":    sa.VARCHAR(20),
        "url":            sa.VARCHAR(200),
    },
    "driver_standings": {
        "driverStandingsId": sa.Integer(),
        "raceId":            sa.Integer(),
        "driverId":          sa.Integer(),
        "points":            sa.Numeric(8, 2),
        "position":          sa.Integer(),
        "positionText":      sa.VARCHAR(5),
        "wins":              sa.Integer(),
    },
    "drivers": {
        "driverId":    sa.Integer(),
        "driverRef":   sa.VARCHAR(25),
        "number":      sa.Integer(),
        "code":        sa.CHAR(3),
        "forename":    sa.VARCHAR(30),
        "surname":     sa.VARCHAR(30),
        "dob":         sa.Date(),
        "nationality": sa.VARCHAR(20),
        "url":         sa.VARCHAR(200),
    },
    "fatal_accidents_drivers": {
        "Driver":           sa.VARCHAR(50),
        "Age":              sa.Integer(),
        "Date Of Accident": sa.VARCHAR(15),
        "Event":            sa.VARCHAR(60),
        "Car":              sa.VARCHAR(30),
        "Session":          sa.VARCHAR(20),
    },
    "fatal_accidents_marshalls": {
        "Name":             sa.VARCHAR(50),
        "Age":              sa.Integer(),
        "Date Of Accident": sa.VARCHAR(15),
        "Event":            sa.VARCHAR(60),
    },
    "lap_times": {
        "raceId":       sa.Integer(),
        "driverId":     sa.Integer(),
        "lap":          sa.SmallInteger(),
        "position":     sa.SmallInteger(),
        "time":         sa.VARCHAR(15),
        "milliseconds": sa.Integer(),
    },
    "pit_stops": {
        "raceId":       sa.Integer(),
        "driverId":     sa.Integer(),
        "stop":         sa.SmallInteger(),
        "lap":          sa.SmallInteger(),
        "time":         sa.VARCHAR(10),
        "duration":     sa.VARCHAR(15),
        "milliseconds": sa.Integer(),
    },
    "qualifying": {
        "qualifyId":     sa.Integer(),
        "raceId":        sa.Integer(),
        "driverId":      sa.Integer(),
        "constructorId": sa.Integer(),
        "number":        sa.SmallInteger(),
        "position":      sa.SmallInteger(),
        "q1":            sa.VARCHAR(12),
        "q2":            sa.VARCHAR(12),
        "q3":            sa.VARCHAR(12),
    },
    "races": {
        "raceId":      sa.Integer(),
        "year":        sa.SmallInteger(),
        "round":       sa.SmallInteger(),
        "circuitId":   sa.Integer(),
        "name":        sa.VARCHAR(50),
        "date":        sa.Date(),
        "time":        sa.VARCHAR(10),
        "url":         sa.VARCHAR(150),
        "fp1_date":    sa.Date(),
        "fp1_time":    sa.VARCHAR(10),
        "fp2_date":    sa.Date(),
        "fp2_time":    sa.VARCHAR(10),
        "fp3_date":    sa.Date(),
        "fp3_time":    sa.VARCHAR(10),
        "quali_date":  sa.Date(),
        "quali_time":  sa.VARCHAR(10),
        "sprint_date": sa.Date(),
        "sprint_time": sa.VARCHAR(10),
    },
    "red_flags": {
        "Race":     sa.VARCHAR(50),
        "Lap":      sa.SmallInteger(),
        "Resumed":  sa.VARCHAR(5),
        "Incident": sa.VARCHAR(500),
        "Excluded": sa.VARCHAR(500),
    },
    "results": {
        "resultId":        sa.Integer(),
        "raceId":          sa.Integer(),
        "driverId":        sa.Integer(),
        "constructorId":   sa.Integer(),
        "number":          sa.SmallInteger(),
        "grid":            sa.SmallInteger(),
        "position":        sa.SmallInteger(),
        "positionText":    sa.VARCHAR(5),
        "positionOrder":   sa.SmallInteger(),
        "points":          sa.Numeric(6, 2),
        "laps":            sa.SmallInteger(),
        "time":            sa.VARCHAR(20),
        "milliseconds":    sa.Integer(),
        "fastestLap":      sa.SmallInteger(),
        "rank":            sa.SmallInteger(),
        "fastestLapTime":  sa.VARCHAR(12),
        "fastestLapSpeed": sa.Numeric(6, 3),
        "statusId":        sa.Integer(),
    },
    "safety_cars": {
        "Race":      sa.VARCHAR(50),
        "Cause":     sa.VARCHAR(30),
        "Deployed":  sa.SmallInteger(),
        "Retreated": sa.SmallInteger(),
        "FullLaps":  sa.SmallInteger(),
    },
    "seasons": {
        "year": sa.SmallInteger(),
        "url":  sa.VARCHAR(150),
    },
    "sprint_results": {
        "resultId":       sa.Integer(),
        "raceId":         sa.Integer(),
        "driverId":       sa.Integer(),
        "constructorId":  sa.Integer(),
        "number":         sa.SmallInteger(),
        "grid":           sa.SmallInteger(),
        "position":       sa.SmallInteger(),
        "positionText":   sa.VARCHAR(5),
        "positionOrder":  sa.SmallInteger(),
        "points":         sa.SmallInteger(),
        "laps":           sa.SmallInteger(),
        "time":           sa.VARCHAR(20),
        "milliseconds":   sa.Integer(),
        "fastestLap":     sa.SmallInteger(),
        "fastestLapTime": sa.VARCHAR(12),
        "statusId":       sa.SmallInteger(),
        "rank":           sa.SmallInteger(),
    },
    "status": {
        "statusId": sa.Integer(),
        "status":   sa.VARCHAR(25),
    },
}

# ─────────────────────────────────────────────
#  LIGAÇÃO
# ─────────────────────────────────────────────
def criar_engine(database="master"):
    if AUTH_MODE == "windows":
        conn_str = (
            f"mssql+pyodbc://{SERVER}/{database}"
            f"?driver={DRIVER.replace(' ', '+')}"
            f"&trusted_connection=yes"
        )
    else:
        conn_str = (
            f"mssql+pyodbc://{SQL_USER}:{SQL_PASS}@{SERVER}/{database}"
            f"?driver={DRIVER.replace(' ', '+')}"
        )
    return sa.create_engine(conn_str, fast_executemany=True)


def criar_database():
    engine = criar_engine("master")
    with engine.connect() as conn:
        conn.execution_options(isolation_level="AUTOCOMMIT")
        exists = conn.execute(
            text(f"SELECT COUNT(*) FROM sys.databases WHERE name = '{DB_NAME}'")
        ).scalar()
        if not exists:
            conn.execute(text(f"CREATE DATABASE [{DB_NAME}]"))
            print(f"✅ Base de dados '{DB_NAME}' criada.")
        else:
            print(f"ℹ️  Base de dados '{DB_NAME}' já existe — a usar existente.")
    engine.dispose()


# ─────────────────────────────────────────────
#  CARREGAR CSVs
# ─────────────────────────────────────────────
DATE_COLS = {
    "drivers":  ["dob"],
    "races":    ["date", "fp1_date", "fp2_date", "fp3_date",
                 "quali_date", "sprint_date"],
}

def carregar_csv(nome_tabela, ficheiro):
    parse_dates = DATE_COLS.get(nome_tabela, [])
    df = pd.read_csv(
        os.path.join(CSV_DIR, ficheiro),
        na_values=["\\N", "\\\\N"],
        keep_default_na=True,
    )
    # Converter datas
    for col in parse_dates:
        if col in df.columns:
            df[col] = pd.to_datetime(df[col], errors="coerce")
    # Converter colunas numéricas que estão como float com .0
    for col, sqltype in SQL_TYPES.get(nome_tabela, {}).items():
        if col in df.columns and isinstance(sqltype, (sa.Integer, sa.SmallInteger)):
            df[col] = pd.to_numeric(df[col], errors="coerce").astype("Int64")
    return df


FICHEIROS = {
    "circuits":                  "circuits.csv",
    "constructors":              "constructors.csv",
    "drivers":                   "drivers.csv",
    "seasons":                   "seasons.csv",
    "status":                    "status.csv",
    "races":                     "races.csv",
    "constructor_results":       "constructor_results.csv",
    "constructor_standings":     "constructor_standings.csv",
    "driver_standings":          "driver_standings.csv",
    "qualifying":                "qualifying.csv",
    "results":                   "results.csv",
    "sprint_results":            "sprint_results.csv",
    "lap_times":                 "lap_times.csv",
    "pit_stops":                 "pit_stops.csv",
    "safety_cars":               "safety_cars.csv",
    "red_flags":                 "red_flags.csv",
    "fatal_accidents_drivers":   "fatal_accidents_drivers.csv",
    "fatal_accidents_marshalls": "fatal_accidents_marshalls.csv",
}


def main():
    print("=" * 50)
    print(f"  F1 Operacional — Carga inicial")
    print("=" * 50)

    # 1. Criar BD
    criar_database()

    engine = criar_engine(DB_NAME)

    # 2. Carregar cada tabela
    for tabela, ficheiro in FICHEIROS.items():
        path = os.path.join(CSV_DIR, ficheiro)
        if not os.path.exists(path):
            print(f"⚠️  Ficheiro não encontrado: {ficheiro} — a saltar.")
            continue

        print(f"\n📥 {tabela}...", end=" ", flush=True)
        df = carregar_csv(tabela, ficheiro)
        tipos = SQL_TYPES.get(tabela, {})

        df.to_sql(
            name=tabela,
            con=engine,
            if_exists="replace",   # apaga e recria se já existir
            index=False,
            dtype=tipos,
            chunksize=BATCH_SIZE,
        )
        print(f"{len(df):,} linhas ✅")

    engine.dispose()
    print("\n" + "=" * 50)
    print(f"  Concluído! BD '{DB_NAME}' pronta.")
    print("=" * 50)


if __name__ == "__main__":
    main()
