# Formula 1 Data Warehouse

Academic BI project for a Master's course in Data Science - a complete Business Intelligence solution centered on Formula 1.


# 0_preparacao — Fonte de Dados Original

Esta pasta contém os dados de origem do projeto e o script para criar a base de dados operacional no SQL Server.

## Conteúdo

| Ficheiro | Descrição |
|---|---|
| `criar_bd_operacional.py` | Script Python que cria a BD `f1_operacional` e popula as 18 tabelas |
| `circuits.csv` | Circuitos / pistas (78 registos) |
| `races.csv` | Corridas por época, 1950–2026 (1171 registos) |
| `drivers.csv` | Pilotos (865 registos) |
| `constructors.csv` | Construtores / equipas (214 registos) |
| `results.csv` | Resultados de corrida (27370 registos) |
| `driver_standings.csv` | Classificação de pilotos por corrida (35493 registos) |
| `constructor_standings.csv` | Classificação de construtores por corrida (13697 registos) |
| `constructor_results.csv` | Pontos por construtor por corrida (12931 registos) |
| `qualifying.csv` | Resultados de qualificação (11102 registos) |
| `sprint_results.csv` | Resultados de corridas sprint (546 registos) |
| `lap_times.csv` | Tempos de volta (872521 registos) |
| `pit_stops.csv` | Paragens em pit stop (22335 registos) |
| `safety_cars.csv` | Incidentes de safety car (370 registos) |
| `red_flags.csv` | Bandeiras vermelhas (99 registos) |
| `fatal_accidents_drivers.csv` | Acidentes fatais — pilotos (51 registos) |
| `fatal_accidents_marshalls.csv` | Acidentes fatais — comissários (5 registos) |
| `seasons.csv` | Épocas (77 registos) |
| `status.csv` | Códigos de estado de chegada (140 registos) |

## Como recriar a BD operacional

### Pré-requisitos
```
pip install pandas sqlalchemy pyodbc
```
Requer SQL Server instalado localmente e ODBC Driver 17 (ou superior) para SQL Server.

### Configuração
Abre `criar_bd_operacional.py` e ajusta as variáveis no topo:

```python
SERVER    = r"localhost"   # nome da instância SQL Server
AUTH_MODE = "windows"      # "windows" ou "sql"
SQL_USER  = "sa"           # só se AUTH_MODE = "sql"
SQL_PASS  = "..."          # só se AUTH_MODE = "sql"
```

### Execução
```
python criar_bd_operacional.py
```

O script cria automaticamente a BD `f1_operacional` se não existir, e popula as 18 tabelas. Pode ser re-executado sem problemas — faz `replace` nas tabelas existentes.
