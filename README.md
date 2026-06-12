# Formula 1 Data Warehouse

Academic BI project for a Master's course in Data Science - a complete Business Intelligence solution centered on Formula 1.

## Overview

End-to-end BI pipeline covering extraction, transformation, loading (ETL), and analytical dashboards. Built around a dimensional star-schema Data Warehouse with data spanning 1950–2026 from CSV datasets, high-frequency telemetry JSON, and weather/session data from 2024–2026.

## Repository Structure

```
├── docs/                 # Project documentation (Portuguese)
│   ├── descricao_projeto.md   # Project description & stakeholder analysis
│   ├── prd.md                 # Product Requirements Document
│   ├── narrativa_dados.md     # Data storytelling ("A Anatomia de uma Vitória")
│   ├── estudo-fontes.md       # Source data study & metadata
│   └── enunciado_bi.pdf       # Original assignment
├── project/
│   ├── data/                  # All data files (see .gitignore)
│   │   ├── *.csv              # Historical OLTP data (17 tables)
│   │   ├── virtual_safety_car_estimates.json
│   │   ├── 2024/              # 25 GPs + Pre-Season (70k+ JSON files)
│   │   ├── 2025/              # 25 GPs + Pre-Season (72k+ JSON files)
│   │   └── 2026/              # 7 GPs + Pre-Season (29k+ JSON files)
│   └── report/                # Dashboard specs & BI report
│       ├── dashboards_spec.md
│       └── bi_relatorio.docx
└── README.md
```

## Dimensional Model

- **Fact Table:** `Fact_Performance` (driver-race grain)
- **Dimensions:** `Dim_Tempo`, `Dim_Piloto` (SCD Type 2), `Dim_Circuito`, `Dim_Construtor`

## ETL Pipeline

Python (pandas) + SQL Server Integration Services (SSIS) — incremental refresh within 24h after each Grand Prix.

## Dashboards (Power BI)

1. **Constructor Executive Panel** — pit stops, reliability, points geography, strategy
2. **Driver Performance Panel** — consistency, overtaking, teammate comparisons
3. **Circuit Analysis Panel** — pole-to-win, Safety Car impact, sector overtakes, undercut/overcut

## Data Sources

- Ergast-compatible historical CSV dataset (1950–2026)
- OpenF1 API telemetry & session data (2024–2026)
- Weather data per session
