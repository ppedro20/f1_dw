# Modelo Dimensional — F1 Data Warehouse

---

## Factos

### fact_resultado_corrida
**O que mede:** resultado de cada piloto em cada corrida  
**Granularidade:** 1 linha por piloto por corrida  
**Fonte principal:** `results`

| Medida | Tipo SQL | Fonte | Notas |
|---|---|---|---|
| pontos | DECIMAL(6,2) | results.points | |
| posicao_grid | SMALLINT | results.grid | NULL se não arrancou |
| posicao_final | SMALLINT | results.position | NULL se não terminou |
| posicoes_ganhas | SMALLINT | calculado | posicao_grid - posicao_final |
| voltas_completadas | SMALLINT | results.laps | |
| tempo_corrida_ms | INT | results.milliseconds | |
| tempo_volta_rapida_ms | INT | results.fastestLapTime | converter MM:SS.mmm → ms |
| velocidade_volta_rapida | DECIMAL(6,3) | results.fastestLapSpeed | km/h |

**Dimensões:**

| Chave | Dimensão |
|---|---|
| sk_data | dim_data |
| sk_piloto | dim_piloto |
| sk_construtor | dim_construtor |
| sk_circuito | dim_circuito |
| sk_corrida | dim_corrida |
| sk_estado | dim_estado |

---

### fact_pit_stop
**O que mede:** cada paragem em pit stop durante uma corrida  
**Granularidade:** 1 linha por paragem por piloto por corrida  
**Fonte principal:** `pit_stops` (disponível desde 2011)

| Medida | Tipo SQL | Fonte | Notas |
|---|---|---|---|
| numero_paragem | SMALLINT | pit_stops.stop | 1ª, 2ª, 3ª... |
| volta | SMALLINT | pit_stops.lap | |
| duracao_ms | INT | pit_stops.milliseconds | |

**Dimensões:**

| Chave | Dimensão |
|---|---|
| sk_data | dim_data |
| sk_piloto | dim_piloto |
| sk_construtor | dim_construtor |
| sk_corrida | dim_corrida |

---

### fact_incidente_seguranca
**O que mede:** intervenções de safety car, bandeiras vermelhas e acidentes fatais  
**Granularidade:** 1 linha por incidente por corrida  
**Fonte principal:** `safety_cars`, `red_flags`, `fatal_accidents_drivers`, `fatal_accidents_marshalls`

| Medida | Tipo SQL | Fonte | Notas |
|---|---|---|---|
| tipo_incidente | VARCHAR(20) | derivado | 'Safety Car', 'Red Flag', 'Fatal' |
| volta_inicio | SMALLINT | safety_cars.Deployed / red_flags.Lap | |
| volta_fim | SMALLINT | safety_cars.Retreated | NULL para red flags |
| voltas_neutralizadas | SMALLINT | safety_cars.FullLaps | |
| fatal | BIT | derivado | 1 se acidente fatal |

**Dimensões:**

| Chave | Dimensão |
|---|---|
| sk_data | dim_data |
| sk_circuito | dim_circuito |
| sk_corrida | dim_corrida |

---

## Dimensões

### dim_data ⭐ hierarquia
**Hierarquia:** Ano → Semestre → Trimestre → Mês → Semana → Dia  
**Geração:** script Python (gera datas de 1950-01-01 a 2030-12-31)

| Atributo | Tipo SQL | Exemplo |
|---|---|---|
| sk_data (PK) | INT | 19500101 |
| data_completa | DATE | 1950-01-01 |
| dia | SMALLINT | 1 |
| dia_semana | VARCHAR(15) | Domingo |
| num_semana | SMALLINT | 1 |
| mes | SMALLINT | 1 |
| nome_mes | VARCHAR(15) | Janeiro |
| trimestre | SMALLINT | 1 |
| semestre | SMALLINT | 1 |
| ano | SMALLINT | 1950 |
| epoca_f1 | VARCHAR(10) | 1950 |

---

### dim_piloto
**Fonte:** `drivers`

| Atributo | Tipo SQL | Fonte | Exemplo |
|---|---|---|---|
| sk_piloto (PK) | INT IDENTITY | — | 1 |
| nk_piloto | INT | drivers.driverId | 1 |
| nome_completo | VARCHAR(60) | forename + ' ' + surname | Lewis Hamilton |
| codigo | CHAR(3) | drivers.code | HAM |
| numero | SMALLINT | drivers.number | 44 |
| data_nascimento | DATE | drivers.dob | 1985-01-07 |
| nacionalidade | VARCHAR(20) | drivers.nationality | British |

---

### dim_construtor ⭐ hierarquia
**Hierarquia:** País → Construtor  
**Fonte:** `constructors`

| Atributo | Tipo SQL | Fonte | Exemplo |
|---|---|---|---|
| sk_construtor (PK) | INT IDENTITY | — | 1 |
| nk_construtor | INT | constructors.constructorId | 1 |
| nome | VARCHAR(50) | constructors.name | McLaren |
| nacionalidade | VARCHAR(20) | constructors.nationality | British |
| pais | VARCHAR(50) | mapeamento nacionalidade→país | United Kingdom |

---

### dim_circuito ⭐ hierarquia
**Hierarquia:** Continente → País → Circuito  
**Fonte:** `circuits`

| Atributo | Tipo SQL | Fonte | Exemplo |
|---|---|---|---|
| sk_circuito (PK) | INT IDENTITY | — | 1 |
| nk_circuito | INT | circuits.circuitId | 1 |
| nome_circuito | VARCHAR(100) | circuits.name | Albert Park |
| cidade | VARCHAR(50) | circuits.location | Melbourne |
| pais | VARCHAR(50) | circuits.country | Australia |
| continente | VARCHAR(20) | mapeamento país→continente | Oceânia |
| latitude | DECIMAL(10,6) | circuits.lat | -37.849700 |
| longitude | DECIMAL(10,6) | circuits.lng | 144.968000 |

---

### dim_corrida
**Fonte:** `races`

| Atributo | Tipo SQL | Fonte | Exemplo |
|---|---|---|---|
| sk_corrida (PK) | INT IDENTITY | — | 1 |
| nk_corrida | INT | races.raceId | 1 |
| nome_corrida | VARCHAR(50) | races.name | Australian Grand Prix |
| ano | SMALLINT | races.year | 2009 |
| ronda | SMALLINT | races.round | 1 |
| tem_sprint | BIT | sprint_results join | 0 |

---

### dim_estado
**Fonte:** `status`

| Atributo | Tipo SQL | Fonte | Exemplo |
|---|---|---|---|
| sk_estado (PK) | INT IDENTITY | — | 1 |
| nk_estado | INT | status.statusId | 1 |
| descricao | VARCHAR(25) | status.status | Finished |
| categoria | VARCHAR(20) | derivado | Finished / Lapped / Mechanical / Incident / Other |

**Mapeamento de categorias:**
- `Finished` → Finished
- `+1 Lap`, `+2 Laps`, ... → Lapped
- `Engine`, `Gearbox`, `Hydraulics`, `Brakes`, ... → Mechanical
- `Accident`, `Collision`, `Spun off` → Incident
- Outros → Other

---

## Visão geral do star schema

```
                      ┌─────────────┐
                      │  dim_data   │
                      └──────┬──────┘
                             │
┌──────────────┐    ┌────────┴──────────────┐    ┌─────────────────┐
│  dim_piloto  ├────┤ fact_resultado_corrida ├────┤ dim_construtor  │
└──────────────┘    └────────┬──────────────┘    └─────────────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
     ┌────────┴───┐  ┌───────┴──────┐  ┌───┴──────────┐
     │ dim_corrida│  │ dim_circuito │  │  dim_estado  │
     └────────────┘  └──────────────┘  └──────────────┘
```
