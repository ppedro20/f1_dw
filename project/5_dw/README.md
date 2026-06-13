# 5_dw — Data Warehouse f1_dw

Scripts SQL para criar e inicializar o schema do Data Warehouse no SQL Server.

## Ficheiros

| Ficheiro | Descrição |
|---|---|
| `criar_f1_dw.sql` | Cria a BD `f1_dw` + todas as tabelas (dimensões e factos) + índices |
| `popular_dim_data.sql` | Popula `dim_data` com todas as datas de 1950-01-01 a 2030-12-31 |

## Ordem de execução

```
1. criar_f1_dw.sql       → abre em SSMS, executa (F5)
2. popular_dim_data.sql  → abre em SSMS, executa (F5)
3. Voltar ao SSIS (4_etl/) → atualizar Connection Manager f1_dw → correr o pacote
```

## Schema criado

```
f1_dw
├── dim_data           (sk_data = YYYYMMDD, gerada por script)
├── dim_piloto         (sk IDENTITY, nk = driverId)
├── dim_construtor     (sk IDENTITY, nk = constructorId)
├── dim_circuito       (sk IDENTITY, nk = circuitId)
├── dim_corrida        (sk IDENTITY, nk = raceId)
├── dim_estado         (sk IDENTITY, nk = statusId)
├── fact_resultado_corrida   (6 FK → todas as dimensões)
├── fact_pit_stop            (4 FK → data, piloto, construtor, corrida)
└── fact_incidente_seguranca (3 FK → data, circuito, corrida)
```
