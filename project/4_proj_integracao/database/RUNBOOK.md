# RUNBOOK — F1_DB

Base de dados OLTP que espelha as fontes de dados originais (CSV + JSON) e serve de origem para o **F1_DW** (OLAP/star schema).

---

## Arquitetura

```
project/4_proj_integracao/database/
├── RUNBOOK.md                 ← este ficheiro
├── sql/                       ← scripts DDL (ordem numerica)
│   ├── 01_create_database.sql
│   ├── 02_stg_csv_tables.sql
│   ├── 03_stg_json_tables.sql
│   └── 04_indexes.sql
└── etl/                       ← scripts de ingestao
    ├── ingest.py
    └── requirements.txt
```

**Pipeline:**

```
CSV + JSON  ──►  ingest.py  ──►  F1_DB (OLTP)  ──►  ETL futuro  ──►  F1_DW (OLAP)
```

---

## Pre-requisitos

| Componente | Versao |
|-----------|--------|
| SQL Server | 2019+ (ou Express) |
| Python | 3.10+ |
| ODBC Driver 17+ | `ODBC Driver 17 for SQL Server` |

### Criar virtual environment e instalar dependencias

```bash
cd project/4_proj_integracao/database/etl
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

## 1. Criar a Base de Dados

Executar os scripts SQL por ordem no SQL Server Management Studio (SSMS) ou `sqlcmd`:

```bash
sqlcmd -S localhost -E -i sql\01_create_database.sql
sqlcmd -S localhost -E -i sql\02_stg_csv_tables.sql
sqlcmd -S localhost -E -i sql\03_stg_json_tables.sql
sqlcmd -S localhost -E -i sql\04_indexes.sql
```

**Ou** abrir cada ficheiro no SSMS e executar em sequencia (`F5`).

### O que cada script faz

| Script | Efeito |
|--------|--------|
| `01_create_database.sql` | Cria a base de dados `F1_DB` |
| `02_stg_csv_tables.sql` | Cria 19 tabelas (espelho dos CSVs) com PKs |
| `03_stg_json_tables.sql` | Cria `sessions` + 7 tabelas para dados JSON |
| `04_indexes.sql` | Cria 28 indices em FKs e colunas de join |

### Tabelas criadas

**CSV (19 tabelas):**
`circuits`, `constructors`, `drivers`, `seasons`, `status`, `races`, `results`, `sprint_results`, `lap_times`, `pit_stops`, `qualifying`, `constructor_results`, `constructor_standings`, `driver_standings`, `safety_cars`, `red_flags`, `fatal_accidents_drivers`, `fatal_accidents_marshalls`

**JSON (8 tabelas):**
`sessions`, `weather`, `session_drivers`, `session_corners`, `race_control_msgs`, `driver_laptimes`, `telemetry`, `virtual_safety_car`

---

## 2. Ingestao de Dados

### Configurar conexao

Editar no topo do `etl/ingest.py` se necessario:

```python
DB_CONNECTION = (
    "mssql+pyodbc://localhost/F1_DB?driver=ODBC+Driver+17+for+SQL+Server"
    "&trusted_connection=yes"
)
```

Para autenticacao SQL (em vez de Windows):

```python
DB_CONNECTION = (
    "mssql+pyodbc://sa:password@localhost/F1_DB?driver=ODBC+Driver+17+for+SQL+Server"
)
```

### Executar ingestao

```bash
python project/4_proj_integracao/database/etl/ingest.py
```

### Fluxo do script

```
1. Conexao a base de dados
2. Carga de CSVs (por ordem de FK):
   seasons → circuits → constructors → drivers → status → races →
   results → sprint_results → lap_times → pit_stops → qualifying →
   constructor_results → constructor_standings → driver_standings →
   safety_cars → red_flags → fatal_accidents_*
3. Carga do virtual_safety_car_estimates.json
4. Scan de pastas {ano}/{GP}/Race/ e carga pasta a pasta:
   a. Registar sessao
   b. weather.json
   c. drivers.json
   d. corners.json
   e. rcm.json
   f. {code}/laptimes.json (por piloto)
   g. {code}/{n}_tel.json (telemetria, batch 10k linhas)
```

### Estimativa de duraçao

| Fase | Estimativa |
|------|-----------|
| CSVs (19 ficheiros) | ~30 seg |
| Virtual Safety Car | ~1 seg |
| Sessoes Race (59 pastas) | ~5-15 min (depende do volume de telemetria) |
| **Total** | **~5-15 min** |

---

## 3. Verificacao

Apos a ingestao, confirmar com:

```sql
USE F1_DB;

-- Total de tabelas
SELECT name FROM sys.tables ORDER BY name;

-- Linhas por tabela
SELECT
    t.name AS tabela,
    SUM(p.rows) AS linhas
FROM sys.tables t
JOIN sys.partitions p ON t.object_id = p.object_id AND p.index_id IN (0,1)
GROUP BY t.name
ORDER BY t.name;
```

---

## 4. Reprocessamento

Para recarregar tudo (por exemplo, apos alteracoes nos CSVs):

```sql
-- Opcao A: apagar e recriar a base de dados
DROP DATABASE F1_DB;
-- depois reexecutar os 4 scripts SQL + ingest.py

-- Opcao B: truncar todas as tabelas (mantem a estrutura)
EXEC sp_MSforeachtable 'TRUNCATE TABLE ?';
```

O `ingest.py` usa `if_exists='append'` — se as tabelas ja tiverem dados, as linhas sao adicionadas (causando duplicados). Para recarregar, truncar primeiro.

---

## 5. Estrutura de Ficheiros Fonte

Os dados devem estar em: `project/_data/`

```
_data/
├── circuits.csv               (78 circuitos)
├── constructors.csv           (214 construtores)
├── drivers.csv                (865 pilotos)
├── races.csv                  (1171 corridas)
├── results.csv                (27370 resultados)
├── lap_times.csv              (872521 tempos de volta)
├── pit_stops.csv              (22335 paragens)
├── qualifying.csv             (11102 qualificacoes)
├── sprint_results.csv         (546 sprints)
├── ...
├── virtual_safety_car_estimates.json
├── 2024/
│   └── {Grande Premio}/
│       └── Race/
│           ├── weather.json
│           ├── drivers.json
│           ├── corners.json
│           ├── rcm.json
│           ├── {codigo}/
│           │   ├── laptimes.json
│           │   ├── 1_tel.json
│           │   └── {n}_tel.json
│           └── ...
├── 2025/
└── 2026/
```

---

## 6. Troubleshooting

| Problema | Causa provavel | Solucao |
|----------|---------------|---------|
| `pyodbc.InterfaceError: No driver` | ODBC Driver 17 nao instalado | `https://aka.ms/downloadmsodbcsql` |
| `OperationalError: Login failed` | Autenticacao errada | Verificar user/password na connection string |
| `Table 'xyz' does not exist` | Scripts SQL nao executados | Correr os 4 scripts por ordem |
| `pandas.errors.ParserError` | CSV com formato inesperado | Verificar delimitadores no CSV (devem ser virgulas) |
| `MemoryError` em telemetria | Muitos ficheiros telemetria em simultaneo | O script ja usa chunksize e processa pasta a pasta |
| `KeyError: 'tel'` nalguns JSON | Ficheiro telemetria com estrutura diferente | Log mostra o ficheiro; verificar manualmente |
