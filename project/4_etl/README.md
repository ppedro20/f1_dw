# 4_etl — ETL com SQL Server Integration Services (SSIS)

Projeto Visual Studio com o pipeline ETL completo do `f1_operacional` → `f1_dw`.

## Pré-requisitos

| Ferramenta | Versão mínima |
|---|---|
| Visual Studio 2019 ou 2022 | Community (gratuito) |
| SQL Server Integration Services | Extension SSDT |
| SQL Server | 2019 / 2022 (localhost) |
| BDs criadas | `f1_operacional` (Fase 0) e `f1_dw` (Fase 5) |

**Instalar SSDT (SSIS):** Visual Studio → Extensions → Manage Extensions → pesquisar "SQL Server Integration Services Projects"

---

## Abrir o projeto

1. Abrir `F1_DW_ETL.sln` com Visual Studio
2. Ajustar as passwords nas Connection Managers (se diferente de `password123`)  
   — Solution Explorer → Connection Managers → duplo clique em cada uma

---

## Estrutura do Control Flow

O pacote `F1_ETL_Main.dtsx` tem o seguinte fluxo pré-configurado:

```
ETL_dim_data                  ← gerar datas (Script Task ou SSMS direto)
    ↓
ETL_dim_piloto                ← drivers
    ↓
ETL_dim_construtor            ← constructors
    ↓
ETL_dim_circuito              ← circuits
    ↓
ETL_dim_corrida               ← races + sprint_results
    ↓
ETL_dim_estado                ← status
    ↓
GET_LAST_RESULTADO_ID         ← Execute SQL Task (lê MAX(nk_resultado) do DW)
    ↓
ETL_fact_resultado_corrida    ← results + races
    ↓
GET_LAST_PITSTOP_ID           ← Execute SQL Task
    ↓
ETL_fact_pit_stop             ← pit_stops
    ↓
GET_LAST_INCIDENTE_ID         ← Execute SQL Task
    ↓
ETL_fact_incidente_seguranca  ← safety_cars + red_flags + fatal_accidents
```

---

## Configurar cada Data Flow Task

Para cada `ETL_*`, fazer duplo clique e adicionar:

### Dimensões (ETL_dim_piloto ... ETL_dim_estado)

```
OLE DB Source (f1_operacional)
    → copiar SQL de queries/0X_dim_*.sql
Slowly Changing Dimension (SCD)
    → ligar a f1_dw
    → Business Key: nk_*
    → Fixed Attributes: todos os outros
```

### Factos (ETL_fact_*)

```
OLE DB Source (f1_operacional)
    → copiar SQL de queries/0X_fact_*.sql
    → parâmetro 0 = variável User::LAST_*_ID
OLE DB Destination (f1_dw)
    → tabela: fact_*
    → mapeamento automático (nomes iguais)
```

---

## Notas de carregamento

| Tabela | Tipo | Lógica incremental |
|---|---|---|
| dim_* | SCD Type 1 (Fixed) | SCD gere automaticamente |
| fact_resultado_corrida | Append-only | `WHERE resultId > LAST_RESULTADO_ID` |
| fact_pit_stop | Append-only | `WHERE nk_pit_stop > LAST_PITSTOP_ID` |
| fact_incidente_seguranca | Append-only | Carga completa (volume baixo) |

### dim_data

A `dim_data` é gerada por script SQL, **não por SSIS Source**:
1. Executar `queries/00_dim_data_gerar.sql` diretamente em SSMS (na BD `f1_dw`)
2. O `ETL_dim_data` no Control Flow pode ficar vazio ou usar um Script Task
