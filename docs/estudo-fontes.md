# Estudo das Fontes de Dados Originais e Metadados

## 1. Inventário das Fontes

O repositório `project/data/` contém **22 ficheiros** organizados em três categorias: dados tabulares históricos (CSV), dados de incidentes e segurança (CSV/JSON), e dados de telemetria e sessão (JSON hierárquico por época/corrida/sessão).

### 1.1. Dados Tabulares Históricos (14 ficheiros CSV)

| Ficheiro | Linhas (dados) | Colunas | Chave Primária | Período |
|----------|---------------|---------|----------------|---------|
| `circuits.csv` | 78 | 9 | `circuitId` | n/a |
| `constructor_results.csv` | 12.931 | 5 | `constructorResultsId` | 1958–2026 |
| `constructor_standings.csv` | 13.697 | 7 | `constructorStandingsId` | 1958–2026 |
| `constructors.csv` | 214 | 5 | `constructorId` | n/a |
| `driver_standings.csv` | 35.493 | 7 | `driverStandingsId` | 1950–2026 |
| `drivers.csv` | 865 | 9 | `driverId` | n/a |
| `lap_times.csv` | 872.521 | 6 | composta (`raceId`, `driverId`, `lap`) | 1996–2026 |
| `pit_stops.csv` | 22.335 | 7 | composta (`raceId`, `driverId`, `stop`) | 2011–2026 |
| `qualifying.csv` | 11.102 | 9 | `qualifyId` | 2003–2026 |
| `races.csv` | 1.171 | 18 | `raceId` | 1950–2026 |
| `results.csv` | 27.370 | 18 | `resultId` | 1950–2026 |
| `seasons.csv` | 77 | 2 | `year` | 1950–2026 |
| `sprint_results.csv` | 546 | 17 | `resultId` | 2021–2026 |
| `status.csv` | 140 | 2 | `statusId` | n/a |

### 1.2. Dados de Incidentes e Segurança (5 ficheiros)

| Ficheiro | Linhas | Conteúdo |
|----------|--------|----------|
| `fatal_accidents_drivers.csv` | 51 | Acidentes fatais com pilotos (1952–2015) |
| `fatal_accidents_marshalls.csv` | 5 | Acidentes fatais com comissários (1963–2001) |
| `red_flags.csv` | 99 | Interrupções por bandeira vermelha (1950–2024) |
| `safety_cars.csv` | 370 | Intervenções de Safety Car (1973–2024) |
| `virtual_safety_car_estimates.json` | 78 entradas | Estimativa de voltas sob VSC (2015–2024) |

### 1.3. Dados de Telemetria e Sessão

Estrutura de diretórios: `project/data/{ano}/{Grande Prémio}/{Sessão}/`

| Ano | Grandes Prémios | Sessões por GP |
|-----|----------------|----------------|
| 2024 | 25 | 5 (P1, P2, P3, Qualifying, Race) |
| 2025 | 25 | 5 (P1, P2, P3, Qualifying, Race) |
| 2026 | 9 | 5 (GP) / 3 (Pré-época) |

Cada sessão contém:

| Ficheiro | Descrição |
|----------|-----------|
| `corners.json` | Metadados das curvas do circuito (coordenadas, número) |
| `drivers.json` | Lista de pilotos participantes (código, equipa, nome) |
| `rcm.json` | Race Control Messages (bandeiras, penalidades, incidentes) |
| `session_laptimes.json` | Tempos de volta agregados de todos os pilotos |
| `weather.json` | Condições meteorológicas (temperatura ar/pista, humidade, vento) |
| `{codigo}/laptimes.json` | Tempos por volta, composto de pneu, stint, setores (S1/S2/S3) por piloto |
| `{codigo}/{n}_tel.json` | Telemetria de alta frequência (tempo, aceleração, velocidade, rpm, travão, marcha, volante, GPS) por volta |

---

## 2. Modelo Relacional de Origem

### 2.1. Diagrama de Entidade-Relacionamento

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                                 seasons                                    │
│                         year (PK), url                                     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │ 1:N
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                                 races                                      │
│  raceId (PK), year, round, circuitId (FK), name, date, time, url,          │
│  fp1_date, fp1_time, fp2_date, fp2_time, fp3_date, fp3_time,              │
│  quali_date, quali_time, sprint_date, sprint_time                         │
└──────┬──────────────────────────────────────────────────────────────────────┘
       │ 1:N
       ├──────────────────────────┬──────────────────┬──────────────────┐
       ▼                          ▼                  ▼                  ▼
┌──────────────┐          ┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   results    │          │  lap_times   │    │  pit_stops   │    │  qualifying  │
│──────────────│          │──────────────│    │──────────────│    │──────────────│
│ resultId(PK) │          │ raceId (FK)  │    │ raceId (FK)  │    │ qualifyId(PK)│
│ raceId (FK)  │          │ driverId(FK) │    │ driverId(FK) │    │ raceId (FK)  │
│ driverId(FK) │          │ lap          │    │ stop         │    │ driverId(FK) │
│ constrId(FK) │          │ position     │    │ lap          │    │ constrId(FK) │
│ number       │          │ time         │    │ time         │    │ number       │
│ grid         │          │ milliseconds │    │ duration     │    │ position     │
│ position     │          └──────────────┘    │ milliseconds │    │ q1, q2, q3   │
│ positionText │                              └──────────────┘    └──────────────┘
│ positionOrder│
│ points       │    ┌──────────────┐    ┌──────────────┐
│ laps         │    │   drivers    │    │ constructors │
│ time         │    │──────────────│    │──────────────│
│ milliseconds │    │ driverId(PK) │    │ constrId(PK) │
│ fastestLap   │    │ driverRef    │    │ constructorRef│
│ rank         │◄──►│ number       │    │ name         │
│ fastestLP    │    │ code         │◄──►│ nationality  │
│ fastestSP    │    │ forename     │    │ url          │
│ statusId(FK) │    │ surname      │    └──────┬───────┘
└──────┬───────┘    │ dob          │           │ 1:N
       │ 1:N        │ nationality  │           ▼
       ▼            │ url          │    ┌──────────────────────┐
┌──────────────┐    └──────────────┘    │ constructor_results  │
│   status     │                        │──────────────────────│
│──────────────│    ┌──────────────┐    │ constructorResId(PK) │
│ statusId(PK) │    │  circuits   │    │ raceId (FK)          │
│ status       │    │──────────────│    │ constructorId (FK)   │
└──────────────┘    │ circuitId(PK)│    │ points               │
                    │ circuitRef   │    │ status               │
                    │ name         │    └──────────────────────┘
                    │ location     │
                    │ country      │    ┌──────────────────────┐
                    │ lat          │    │ constructor_standings│
                    │ lng          │    │──────────────────────│
                    │ alt          │    │ constStandId(PK)     │
                    │ url          │    │ raceId (FK)          │
                    └──────────────┘    │ constructorId (FK)   │
                                        │ points, position     │
                    ┌──────────────┐    │ positionText, wins   │
                    │sprint_results│    └──────────────────────┘
                    │──────────────│
                    │ resultId(PK) │    ┌──────────────────────┐
                    │ raceId (FK)  │    │  driver_standings    │
                    │ driverId(FK) │    │──────────────────────│
                    │ constrId(FK) │    │ driverStandId(PK)    │
                    │ (mesma       │    │ raceId (FK)          │
                    │  estrutura   │    │ driverId (FK)        │
                    │  do results) │    │ points, position     │
                    └──────────────┘    │ positionText, wins   │
                                        └──────────────────────┘
```

### 2.2. Relações de Chave Estrangeira

| Tabela (FK) | Coluna | Referencia | Coluna |
|-------------|--------|------------|--------|
| `races` | `circuitId` | `circuits` | `circuitId` |
| `results` | `raceId` | `races` | `raceId` |
| `results` | `driverId` | `drivers` | `driverId` |
| `results` | `constructorId` | `constructors` | `constructorId` |
| `results` | `statusId` | `status` | `statusId` |
| `lap_times` | `raceId` | `races` | `raceId` |
| `lap_times` | `driverId` | `drivers` | `driverId` |
| `pit_stops` | `raceId` | `races` | `raceId` |
| `pit_stops` | `driverId` | `drivers` | `driverId` |
| `qualifying` | `raceId` | `races` | `raceId` |
| `qualifying` | `driverId` | `drivers` | `driverId` |
| `qualifying` | `constructorId` | `constructors` | `constructorId` |
| `sprint_results` | `raceId` | `races` | `raceId` |
| `sprint_results` | `driverId` | `drivers` | `driverId` |
| `sprint_results` | `constructorId` | `constructors` | `constructorId` |
| `sprint_results` | `statusId` | `status` | `statusId` |
| `constructor_results` | `raceId` | `races` | `raceId` |
| `constructor_results` | `constructorId` | `constructors` | `constructorId` |
| `constructor_standings` | `raceId` | `races` | `raceId` |
| `constructor_standings` | `constructorId` | `constructors` | `constructorId` |
| `driver_standings` | `raceId` | `races` | `raceId` |
| `driver_standings` | `driverId` | `drivers` | `driverId` |

---

## 3. Metadados Detalhados

### `circuits` (78 circuitos)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `circuitId` | INTEGER | PK | NOT NULL | Identificador único do circuito |
| `circuitRef` | VARCHAR(50) | - | NOT NULL | Referência textual (ex: `albert_park`) |
| `name` | VARCHAR(100) | - | NOT NULL | Nome oficial do circuito |
| `location` | VARCHAR(100) | - | NULLABLE | Cidade de localização |
| `country` | VARCHAR(50) | - | NULLABLE | País (35 países distintos) |
| `lat` | DECIMAL(10,6) | - | NULLABLE | Latitude |
| `lng` | DECIMAL(10,6) | - | NULLABLE | Longitude |
| `alt` | INTEGER | - | NULLABLE | Altitude em metros |
| `url` | VARCHAR(255) | - | NULLABLE | URL da Wikipedia |

### `constructors` (214 construtores)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `constructorId` | INTEGER | PK | NOT NULL | Identificador único do construtor |
| `constructorRef` | VARCHAR(50) | - | NOT NULL | Referência textual (ex: `mclaren`) |
| `name` | VARCHAR(100) | - | NOT NULL | Nome oficial da equipa |
| `nationality` | VARCHAR(50) | - | NULLABLE | País de origem |
| `url` | VARCHAR(255) | - | NULLABLE | URL da Wikipedia |

### `drivers` (865 pilotos)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `driverId` | INTEGER | PK | NOT NULL | Identificador único do piloto |
| `driverRef` | VARCHAR(50) | - | NOT NULL | Referência textual (ex: `hamilton`) |
| `number` | INTEGER | - | NULLABLE | Número do carro |
| `code` | VARCHAR(3) | - | NULLABLE | Código de 3 letras (HAM, VER, LEC) |
| `forename` | VARCHAR(50) | - | NOT NULL | Primeiro nome |
| `surname` | VARCHAR(50) | - | NOT NULL | Apelido |
| `dob` | DATE | - | NULLABLE | Data de nascimento |
| `nationality` | VARCHAR(50) | - | NULLABLE | Nacionalidade |
| `url` | VARCHAR(255) | - | NULLABLE | URL da Wikipedia |

### `races` (1.171 corridas, 1950–2026)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `raceId` | INTEGER | PK | NOT NULL | Identificador único |
| `year` | INTEGER | - | NOT NULL | Época |
| `round` | INTEGER | - | NOT NULL | Ronda da época |
| `circuitId` | INTEGER | FK | NOT NULL | Circuito |
| `name` | VARCHAR(100) | - | NOT NULL | Nome do Grande Prémio |
| `date` | DATE | - | NOT NULL | Data da corrida |
| `time` | TIME | - | NULLABLE | Hora de início |
| `url` | VARCHAR(255) | - | NULLABLE | URL da Wikipedia |
| `fp1_date` | DATE | - | NULLABLE | Data do treino livre 1 |
| `fp1_time` | TIME | - | NULLABLE | Hora do treino livre 1 |
| `fp2_date` | DATE | - | NULLABLE | Data do treino livre 2 |
| `fp2_time` | TIME | - | NULLABLE | Hora do treino livre 2 |
| `fp3_date` | DATE | - | NULLABLE | Data do treino livre 3 |
| `fp3_time` | TIME | - | NULLABLE | Hora do treino livre 3 |
| `quali_date` | DATE | - | NULLABLE | Data da qualificação |
| `quali_time` | TIME | - | NULLABLE | Hora da qualificação |
| `sprint_date` | DATE | - | NULLABLE | Data da sprint |
| `sprint_time` | TIME | - | NULLABLE | Hora da sprint |

### `results` (27.370 registos, 1950–2026)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `resultId` | INTEGER | PK | NOT NULL | Identificador único |
| `raceId` | INTEGER | FK | NOT NULL | Corrida associada |
| `driverId` | INTEGER | FK | NOT NULL | Piloto |
| `constructorId` | INTEGER | FK | NOT NULL | Construtor |
| `number` | INTEGER | - | NOT NULL | Número do carro |
| `grid` | INTEGER | - | NOT NULL | Posição de partida |
| `position` | INTEGER | - | NULLABLE | Posição final (NULL = não classificado) |
| `positionText` | VARCHAR(10) | - | NOT NULL | "1", "R", "DNF", "W", etc. |
| `positionOrder` | INTEGER | - | NOT NULL | Ordem de classificação numérica |
| `points` | DECIMAL(8,2) | - | NOT NULL | Pontos conquistados |
| `laps` | INTEGER | - | NOT NULL | Voltas completadas |
| `time` | VARCHAR(30) | - | NULLABLE | Tempo total (ou diferença) |
| `milliseconds` | INTEGER | - | NULLABLE | Tempo total em ms |
| `fastestLap` | INTEGER | - | NULLABLE | N.º da volta mais rápida |
| `rank` | INTEGER | - | NULLABLE | Ranking da volta mais rápida |
| `fastestLapTime` | VARCHAR(20) | - | NULLABLE | Tempo da volta mais rápida |
| `fastestLapSpeed` | DECIMAL(8,3) | - | NULLABLE | Velocidade média (km/h) |
| `statusId` | INTEGER | FK | NOT NULL | Estado de término |

### `lap_times` (872.521 registos, 1996–2026)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `raceId` | INTEGER | FK | NOT NULL | Corrida associada |
| `driverId` | INTEGER | FK | NOT NULL | Piloto |
| `lap` | INTEGER | PK | NOT NULL | Número da volta |
| `position` | INTEGER | - | NOT NULL | Posição do piloto nessa volta |
| `time` | VARCHAR(20) | - | NULLABLE | Tempo da volta (mm:ss.ms) |
| `milliseconds` | INTEGER | - | NULLABLE | Tempo da volta em ms |

### `pit_stops` (22.335 registos, 2011–2026)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `raceId` | INTEGER | FK | NOT NULL | Corrida associada |
| `driverId` | INTEGER | FK | NOT NULL | Piloto |
| `stop` | INTEGER | PK | NOT NULL | Número da paragem |
| `lap` | INTEGER | - | NOT NULL | Volta da paragem |
| `time` | TIME | - | NOT NULL | Hora da paragem |
| `duration` | DECIMAL(8,3) | - | NOT NULL | Duração (segundos) |
| `milliseconds` | INTEGER | - | NOT NULL | Duração em ms |

### `qualifying` (11.102 registos, 2003–2026)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `qualifyId` | INTEGER | PK | NOT NULL | Identificador único |
| `raceId` | INTEGER | FK | NOT NULL | Corrida associada |
| `driverId` | INTEGER | FK | NOT NULL | Piloto |
| `constructorId` | INTEGER | FK | NOT NULL | Construtor |
| `number` | INTEGER | - | NOT NULL | Número do carro |
| `position` | INTEGER | - | NOT NULL | Posição final |
| `q1` | VARCHAR(20) | - | NULLABLE | Melhor tempo em Q1 |
| `q2` | VARCHAR(20) | - | NULLABLE | Melhor tempo em Q2 |
| `q3` | VARCHAR(20) | - | NULLABLE | Melhor tempo em Q3 |

### `status` (140 estados)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `statusId` | INTEGER | PK | NOT NULL | Identificador único |
| `status` | VARCHAR(100) | - | NOT NULL | Descrição (Finished, Engine, Collision, +1 Lap, etc.) |

**Distribuição de estados:**
- `Finished` — classificado
- `+N Lap` / `+N Laps` — voltas de atraso
- `Engine`, `Gearbox`, `Transmission`, `Hydraulics`, `Electrical`, etc. — falhas mecânicas
- `Accident`, `Collision`, `Spun off`, `Collision damage` — acidentes
- `Disqualified`, `Excluded`, `Withdrew` — exclusões

### `constructor_results` (12.931 registos)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `constructorResultsId` | INTEGER | PK | NOT NULL | Identificador único |
| `raceId` | INTEGER | FK | NOT NULL | Corrida associada |
| `constructorId` | INTEGER | FK | NOT NULL | Construtor |
| `points` | DECIMAL(8,2) | - | NULLABLE | Pontos na corrida |
| `status` | VARCHAR(20) | - | NULLABLE | "D" se desclassificado |

### `constructor_standings` (13.697 registos)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `constructorStandingsId` | INTEGER | PK | NOT NULL | Identificador único |
| `raceId` | INTEGER | FK | NOT NULL | Corrida associada |
| `constructorId` | INTEGER | FK | NOT NULL | Construtor |
| `points` | DECIMAL(8,2) | - | NOT NULL | Pontos acumulados |
| `position` | INTEGER | - | NULLABLE | Posição no campeonato |
| `positionText` | VARCHAR(10) | - | NULLABLE | Posição em texto |
| `wins` | INTEGER | - | NOT NULL | Vitórias na época |

### `driver_standings` (35.493 registos)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `driverStandingsId` | INTEGER | PK | NOT NULL | Identificador único |
| `raceId` | INTEGER | FK | NOT NULL | Corrida associada |
| `driverId` | INTEGER | FK | NOT NULL | Piloto |
| `points` | DECIMAL(8,2) | - | NOT NULL | Pontos acumulados |
| `position` | INTEGER | - | NULLABLE | Posição no campeonato |
| `positionText` | VARCHAR(10) | - | NULLABLE | Posição em texto |
| `wins` | INTEGER | - | NOT NULL | Vitórias na época |

### `sprint_results` (546 registos, 2021–2026)

Estrutura idêntica a `results` (17 colunas), com os campos: `resultId`, `raceId`, `driverId`, `constructorId`, `number`, `grid`, `position`, `positionText`, `positionOrder`, `points`, `laps`, `time`, `milliseconds`, `fastestLap`, `fastestLapTime`, `statusId`, `rank`.

### `seasons` (77 épocas, 1950–2026)

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|-----------|
| `year` | INTEGER | PK | NOT NULL | Ano da época |
| `url` | VARCHAR(255) | - | NULLABLE | URL da Wikipedia |

---

## 4. Fontes de Incidentes e Segurança

### `safety_cars` (370 registos, 1973–2024)

| Coluna | Tipo | Nulidade | Descrição |
|--------|------|----------|-----------|
| `Race` | VARCHAR(100) | NOT NULL | Nome do Grande Prémio |
| `Cause` | VARCHAR(100) | NOT NULL | Causa (Accident, Rain, Debris, etc.) |
| `Deployed` | INTEGER | NOT NULL | Volta de ativação |
| `Retreated` | DECIMAL(5,1) | NULLABLE | Volta de recolha |
| `FullLaps` | INTEGER | NULLABLE | Voltas completas sob SC |

**Causas principais:** Accident (191), Stranded car (86), Rain (28), Debris from accident (25).

### `red_flags` (99 registos, 1950–2024)

| Coluna | Tipo | Nulidade | Descrição |
|--------|------|----------|-----------|
| `Race` | VARCHAR(100) | NOT NULL | Nome do Grande Prémio |
| `Lap` | INTEGER | NOT NULL | Volta da interrupção |
| `Resumed` | VARCHAR(5) | NOT NULL | "Y" = retomada, "N" = cancelada |
| `Incident` | TEXT | NULLABLE | Descrição textual |
| `Excluded` | TEXT | NULLABLE | Entidades excluídas |

### `fatal_accidents_drivers` (51 registos, 1952–2015)

| Coluna | Tipo | Nulidade | Descrição |
|--------|------|----------|-----------|
| `Driver` | VARCHAR(100) | NOT NULL | Nome do piloto |
| `Age` | INTEGER | NOT NULL | Idade |
| `Date Of Accident` | DATE | NOT NULL | Data |
| `Event` | VARCHAR(100) | NOT NULL | Evento |
| `Car` | VARCHAR(100) | NULLABLE | Construtor |
| `Session` | VARCHAR(50) | NOT NULL | Practice, Race, Test |

### `fatal_accidents_marshalls` (5 registos, 1963–2001)

| Coluna | Tipo | Nulidade | Descrição |
|--------|------|----------|-----------|
| `Name` | VARCHAR(100) | NOT NULL | Nome |
| `Age` | INTEGER | NOT NULL | Idade |
| `Date Of Accident` | DATE | NOT NULL | Data |
| `Event` | VARCHAR(100) | NOT NULL | Evento |

### `virtual_safety_car_estimates.json` (78 entradas, 2015–2024)

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Chave | VARCHAR | "YYYY Nome Do Grande Prémio" |
| Valor | ARRAY[INTEGER] | Voltas onde o VSC esteve ativo |

---

## 5. Dados de Telemetria e Sessão

### 5.1. Estrutura por Sessão

Cada sessão (Practice 1/2/3, Qualifying, Race) contém:

**`session_laptimes.json`** — array de tempos de volta (em segundos) de todos os pilotos, sequencial por volta.

**`weather.json`** — dados meteorológicos ao longo da sessão:
- `wT` — temperatura da pista (track temperature ×10) ao longo do tempo
- `wAT` — temperatura do ar (air temperature)
- `wHum` — humidade
- `wWindSpeed` — velocidade do vento
- `wWindDir` — direção do vento

**`drivers.json`** — lista de pilotos na sessão com código, equipa, número, nome.

**`corners.json`** — metadados das curvas (número, zona DRS, coordenadas GPS).

**`rcm.json`** — mensagens da direção de prova (bandeiras, safety car, penalidades).

### 5.2. Telemetria por Piloto

Pasta `{codigo_piloto}/` contém:
- **`laptimes.json`** — dados por volta:
  - `lap` — número da volta
  - `time` — tempo da volta (s)
  - `compound` — composto de pneu (SOFT, MEDIUM, HARD, INTERMEDIATE, WET)
  - `stint` — número do stint
  - `s1`, `s2`, `s3` — tempos de setor
  - `s1Speed`, `s2Speed`, `s3Speed` — velocidades médias por setor
- **`{n}_tel.json`** — telemetria de alta frequência da volta n:
  - `time` — instantes de amostragem (s)
  - `speed` — velocidade (km/h)
  - `rpm` — rotação do motor
  - `gear` — marcha engaged
  - `throttle` — posição do acelerador (%)
  - `brake` — pressão do travão
  - `drs` — DRS ativo (0/1)
  - `x`, `y`, `z` — coordenadas GPS
  - `distance` — distância percorrida na volta (m)

---

## 6. Qualidade dos Dados

### 6.1. Observações

| Aspeto | Observação |
|--------|-----------|
| **Nulidades** | Campos `position`, `time`, `milliseconds` em `results` são NULL quando o piloto não classificou |
| **Valores especiais** | `positionText` contém "R" (Retired), "DNF" (Did Not Finish), "W" (Withdrew), "N" (Not classified) |
| **Chaves compostas** | `lap_times` e `pit_stops` usam chaves compostas — requerem JOIN com `races` e `drivers` |
| **Sobreposição temporal** | `lap_times` começa em 1996, `pit_stops` em 2011, `qualifying` em 2003, `sprint_results` em 2021 |
| **Dados de telemetria** | Disponíveis apenas para 2024–2026; `session_laptimes.json` contém arrays densos (não inclui identificadores de piloto/volta — requer parsing posicional) |
| **Safety Cars** | A ligação entre `safety_cars.Race` e `races.name` requer matching textual (ano + nome do GP) |
| **Consistência geográfica** | `circuits.country` tem "USA" e "United States" como entradas distintas |

### 6.2. Cobertura Temporal

| Fonte | Início | Fim | Cobertura |
|-------|--------|-----|-----------|
| `seasons` | 1950 | 2026 | Completa |
| `races` | 1950 | 2026 | Completa |
| `results` | 1950 | 2026 | Completa |
| `driver_standings` | 1950 | 2026 | Completa |
| `constructors` / `constructor_*` | 1958 | 2026 | Completa |
| `lap_times` | 1996 | 2026 | Parcial (só a partir de 1996) |
| `qualifying` | 2003 | 2026 | Parcial |
| `pit_stops` | 2011 | 2026 | Parcial |
| `sprint_results` | 2021 | 2026 | Parcial |
| Telemetria (sessão) | 2024 | 2026 | Apenas épocas recentes |
| `safety_cars` | 1973 | 2024 | Histórico |
| `red_flags` | 1950 | 2024 | Histórico |

---

## 7. Matriz de Mapeamento para o Modelo Dimensional

## 7. Modelo Dimensional (Star Schema — Constelação de Factos)

### 7.1. Factos, Dimensões e Hierarquias

**Assunto de Análise:** Performance em Corrida

O modelo adota uma **constelação de factos** com dois níveis de granularidade, partilhando as dimensões conformadas:

**Fact_Performance** (grão: piloto × corrida)
- Medidas: Pontos_Conquistados, Tempo_Total_Pit_Stops, Num_Pit_Stops, Posicoes_Ganhas, Posicao_Partida, Posicao_Final, Abandono_Mecanico

**Fact_Volta** (grão: piloto × corrida × volta)
- Medidas: Tempo_Volta_ms, Tempo_S1/S2/S3, Posicao_na_Volta, Volta_Sob_SC, Paragem_Box
- Dimensões degeneradas: Num_Volta, Stint

**Dimensões (5):**

1. **Dim_Tempo:** Granularidade ao nível do dia, hierarquia Ano → Trimestre → Mês → Dia (atributos: Data_SK, Ano, Trimestre, Mes, Dia, Dia_Semana).
2. **Dim_Piloto:** Atributos — Nome_Completo, Nacionalidade, Data_Nascimento, Equipa (SCD Tipo 2), Data_Inicio, Data_Fim.
3. **Dim_Circuito:** Hierarquia Continente → País → Cidade → Circuito; inclui Altitude.
4. **Dim_Construtor:** Atributos — Nome, País, Motorizador.
5. **Dim_Composto:** Atributos — Composto (SOFT/MEDIUM/HARD/INTERMEDIATE/WET/Desconhecido), Tipo_Piso (Seco/Chuva).

### 7.2. Diagrama Star Schema

```
                         ┌──────────────────────┐
                         │     Dim_Tempo         │
                         │──────────────────────│
                         │ Data_SK (PK)          │
                         │ Ano, Trimestre        │
                         │ Mes, Dia, Dia_Semana  │
                         └──────────┬───────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              │                     │                     │
   ┌──────────┴───────────┐   ┌────┴───────────┐   ┌─────┴──────────────┐
   │   Fact_Performance    │   │  Fact_Volta    │   │   Dim_Composto     │
   │──────────────────────│   │────────────────│   │────────────────────│
   │ Data_SK (FK)          │   │ Data_SK (FK)   │   │ Composto_SK (PK)   │
   │ Piloto_SK (FK)        │   │ Piloto_SK (FK) │   │ Composto            │
   │ Circuito_SK (FK)      │   │ Circuito_SK(FK)│   │ Tipo_Piso          │
   │ Construtor_SK (FK)    │   │ Construtor_SK  │   └────────────────────┘
   │──────────────────────│   │ Composto_SK    │          │
   │ Pontos_Conquistados  │   │────────────────│          │
   │ Tempo_Total_Pit_Stops│   │ Tempo_Volta_ms │──────────┘
   │ Num_Pit_Stops        │   │ Tempo_S1/S2/S3 │
   │ Posicoes_Ganhas      │   │ Posicao_na_Volta│
   │ Posicao_Partida      │   │ Volta_Sob_SC   │
   │ Posicao_Final        │   │ Paragem_Box    │
   │ Abandono_Mecanico    │   │ Num_Volta (deg)│
   └──┬───────┬───────┬───┘   │ Stint (deg.)   │
      │       │       │       └────────────────┘
 ┌────┘       │       └──────┐
 │            │               │
 ┌──────────┴───────────┐ ┌──┴──────────────┐ ┌──────────┴───────────┐
 │     Dim_Piloto        │ │   Dim_Circuito   │ │  Dim_Construtor     │
 │──────────────────────│ │──────────────────│ │─────────────────────│
 │ Piloto_SK (PK)       │ │ Circuito_SK (PK) │ │ Construtor_SK (PK)  │
 │ Nome_Completo        │ │ Nome_Circuito    │ │ Nome                │
 │ Nacionalidade        │ │ Cidade           │ │ Pais                │
 │ Data_Nascimento      │ │ Pais             │ │ Motorizador         │
 │ Equipa (SCD2)        │ │ Continente       │ └─────────────────────┘
 │ Data_Inicio          │ │ Altitude         │
 │ Data_Fim             │ └──────────────────┘
 └──────────────────────┘
```

### 7.3. Matriz de Mapeamento (Origem → Destino)

| Tabela Origem (OLTP) | Atributo Origem | Tipo Origem | Tabela Destino (DW) | Atributo Destino | Tipo Destino | Transformação / Regra |
|---|---|---|---|---|---|---|
| `races.date` | `date` | DATE | `Dim_Tempo` | `Data_SK` | INTEGER (SK) | DATE → YYYYMMDD |
| `races.date` | `date` | DATE | `Dim_Tempo` | `Ano` | INTEGER | YEAR() |
| `races.date` | `date` | DATE | `Dim_Tempo` | `Mes` | INTEGER | MONTH() |
| `races.date` | `date` | DATE | `Dim_Tempo` | `Dia` | INTEGER | DAY() |
| `results.raceId` + `races.date` | `raceId`, `date` | INT, DATE | `Fact_Performance` | `Data_SK` | INTEGER (FK) | JOIN results.raceId = races.id; date → YYYYMMDD |
| `drivers.forename` + `surname` | `forename`, `surname` | VARCHAR(50) | `Dim_Piloto` | `Nome_Completo` | VARCHAR(101) | CONCAT(forename, ' ', surname) |
| `drivers.nationality` | `nationality` | VARCHAR(50) | `Dim_Piloto` | `Nacionalidade` | VARCHAR(50) | Direto |
| `drivers.dob` | `dob` | DATE | `Dim_Piloto` | `Data_Nascimento` | DATE | Direto |
| `results.constructorId` | `constructorId` | INTEGER | `Dim_Piloto` | `Equipa` | VARCHAR(50) | JOIN constructors.name; SCD Tipo 2 com Data_Inicio/Data_Fim |
| `circuits.name` | `name` | VARCHAR(100) | `Dim_Circuito` | `Nome_Circuito` | VARCHAR(100) | Direto |
| `circuits.location` | `location` | VARCHAR(100) | `Dim_Circuito` | `Cidade` | VARCHAR(100) | Direto |
| `circuits.country` | `country` | VARCHAR(50) | `Dim_Circuito` | `Pais` | VARCHAR(50) | Direto |
| `circuits.country` | `country` | VARCHAR(50) | `Dim_Circuito` | `Continente` | VARCHAR(50) | Lookup geográfica |
| `constructors.name` | `name` | VARCHAR(50) | `Dim_Construtor` | `Nome` | VARCHAR(50) | Direto |
| `constructors.nationality` | `nationality` | VARCHAR(50) | `Dim_Construtor` | `Pais` | VARCHAR(50) | Direto |
| `constructors.name` | `name` | VARCHAR(50) | `Dim_Construtor` | `Motorizador` | VARCHAR(50) | Lookup (ex: Mercedes-AMG → Mercedes) |
| `results.points` | `points` | DECIMAL(8,2) | `Fact_Performance` | `Pontos_Conquistados` | DECIMAL(8,2) | Direto |
| `pit_stops.duration` | `duration` | DECIMAL(8,3) | `Fact_Performance` | `Tempo_Total_Pit_Stops` | DECIMAL(8,3) | SOMA por piloto/corrida |
| `pit_stops.stop` | `stop` | INTEGER | `Fact_Performance` | `Num_Pit_Stops` | INTEGER | COUNT distinto por (raceId, driverId) |
| `results.position` | `position` | INTEGER | `Fact_Performance` | `Posicao_Final` | INTEGER | Direto; NULL = "Não classificado" |
| `results.grid` | `grid` | INTEGER | `Fact_Performance` | `Posicao_Partida` | INTEGER | Direto |
| `results.position` / `grid` | `position`, `grid` | INTEGER | `Fact_Performance` | `Posicoes_Ganhas` | INTEGER | grid - position (0 se NULL) |
| `results.statusId` → `status.status` | `statusId`, `status` | INTEGER, VARCHAR | `Fact_Performance` | `Abandono_Mecanico` | INTEGER (flag) | 1 se status ∈ falha mecânica (Engine, Gearbox, etc.); 0 c.c. |
| --- | --- | --- | --- | --- | --- | --- |
| **Fact_Volta** | | | | | |
| `lap_times.milliseconds` | `milliseconds` | INTEGER | `Fact_Volta` | `Tempo_Volta_ms` | INTEGER | Direto (1996+) |
| `lap_times.position` | `position` | INTEGER | `Fact_Volta` | `Posicao_na_Volta` | INTEGER | Posição no final da volta |
| telemetria `laptimes.s1/s2/s3` | `s1`, `s2`, `s3` | DECIMAL | `Fact_Volta` | `Tempo_S1/S2/S3` | DECIMAL | Matching por código piloto + n.º volta (2024+); NULL antes |
| telemetria `laptimes.compound` | `compound` | VARCHAR | `Dim_Composto` | `Composto` | VARCHAR | Lookup: SOFT, MEDIUM, HARD, INTERMEDIATE, WET |
| telemetria `laptimes.compound` | `compound` | VARCHAR | `Dim_Composto` | `Tipo_Piso` | VARCHAR | "Seco" se SOFT/MEDIUM/HARD; "Chuva" se INTERMEDIATE/WET |
| telemetria `laptimes.compound` | `compound` | VARCHAR | `Fact_Volta` | `Composto_SK` | INTEGER (FK) | Lookup → Dim_Composto; "Desconhecido" antes de 2024 |
| telemetria `laptimes.stint` | `stint` | INTEGER | `Fact_Volta` | `Stint` | INTEGER | Dimensão degenerada |
| `safety_cars.Deployed`–`Retreated` + VSC | `Deployed`, `Retreated` | INTEGER | `Fact_Volta` | `Volta_Sob_SC` | INTEGER (flag) | 1 se volta ∈ [Deployed, Retreated] ∪ VSC; matching textual GP |
| `pit_stops.lap` | `lap` | INTEGER | `Fact_Volta` | `Paragem_Box` | INTEGER (flag) | 1 se existe pit_stop nessa (raceId, driverId, lap) |

### 7.4. Transformações Críticas

- Tratamento de nulos/strings de abandono ("R", "DNF") para codificação numérica padronizada na fact table.
- **SCD Tipo 2** em `Dim_Piloto.Equipa` para histórico de mudanças de equipa; restantes dimensões SCD Tipo 0 ou Tipo 1.
- Cálculo derivado: `Posicoes_Ganhas` = `Posicao_Partida` − `Posicao_Final` (0 se não classificado).
- Cobertura temporal: `Fact_Volta` combina `lap_times` (1996+) com telemetria (2024+); compostos anteriores a 2024 mapeados para "Desconhecido".
- Flag `Volta_Sob_SC`: matching textual entre `safety_cars.Race`/`virtual_safety_car` e `races.name` para determinar intervalos de SC/VSC por volta.
