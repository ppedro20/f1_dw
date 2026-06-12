## 1. Visão Geral do Projeto

### 1.1. Objetivo

Desenvolvimento de uma solução completa de Business Intelligence (BI) focada no domínio da **Formula 1**, cobrindo desde a extração de dados operacionais até à visualização analítica e storytelling. O sistema visa consolidar dados históricos de corridas, pilotos, construtores e circuitos para responder a questões estratégicas e de performance sobre o desporto.

### 1.2. Promotores e Stakeholders

* **Promotor Académico:** Unidade Curricular de Business Intelligence, Mestrado em Ciência de Dados.
* **Sponsor do Projeto:** Direção de Desporto Motorizado da FIA / equipas de F1 (stakeholder simulado para efeitos académicos).
* **Utilizadores-alvo:** Estrategistas de corrida, analistas de performance de equipas, jornalistas especializados e comentadores técnicos.

### 1.3. Requisitos de Grupo e Submissão

* 
**Dimensão do Grupo:** Máximo de 3 estudantes.


* 
**Proposta de Tema:** Submissão via formulário Moodle até 15 de maio.


* 
**Entregáveis Operacionais:** Relatório em formato PDF (modelo IEEE opcional), apresentação PowerPoint, ficheiros das fontes originais e código/soluções dos projetos desenvolvidos.


* 
**Defesa Oral:** Presença obrigatória de todos os membros, sob pena de exclusão (nota zero). Inclui demonstração técnica e narração da história dos dados.



---

## 2. Requisitos de Negócio e Analíticos

Os requisitos foram levantados através de análise documental do desporto (regulamentos FIA, relatórios técnicos de época) e da exploração dos datasets históricos disponíveis, complementada por simulação de entrevistas com os seguintes stakeholders típicos de uma equipa de F1: Diretor Técnico (foco em fiabilidade e performance mecânica), Estrategista de Corrida Chefe (foco em estratégias de paragens e degradação de pneus) e Analista de Dados Sénior (foco em métricas de consistência e ultrapassagens). As entrevistas simuladas revelaram necessidades prioritárias de comparação direta de performance entre equipas, previsão de degradação de pneus por circuito e avaliação de custo-benefício dos investimentos técnicos.

### 2.1. 

Questões de Análise (Mínimo de 10) 

1. Qual é a evolução histórica do tempo médio de pit stop por construtor ao longo das épocas?
2. Existe correlação direta entre a posição de qualificação (pole position) e a vitória final na corrida em circuitos de diferente altitude?
3. Quais os construtores com maior taxa de abandono por falha mecânica em condições de temperatura elevada?
4. Como varia a consistência de tempos por volta de um piloto quando este transita de pneus macios para duros?
5. Qual o impacto estatístico da entrada do Safety Car na alteração das posições finais do Top 10?
6. Em que setor da volta (S1, S2 ou S3) ocorrem mais ultrapassagens em cada circuito?
7. Qual é a distribuição geográfica dos pontos conquistados por nacionalidade de pilotos nos últimos 20 anos?
8. Que pilotos apresentam maior ganho líquido de posições na primeira volta da corrida a partir de posições intermédias da grelha (P10-P15)?
9. Qual é a eficácia de estratégias de *undercut* vs. *overcut* com base no desgaste real dos pneus?
10. Qual o impacto do número de paragens nas boxes (estratégia 2 vs. 3 stops) na posição final do piloto?

### 2.2. User Stories

* **Como** Analista de Performance de uma Equipa de F1, **quero** comparar o tempo de pit stop da minha equipa com os concorrentes diretos **para** identificar janelas de otimização mecânica.
* **Como** Estrategista de Corrida, **quero** simular o impacto de janelas de paragem com base no histórico de degradação de pneu por circuito **para** mitigar o risco de perda de posição em pista.

---

3. Fontes de Dados e Metadados 

### 3.1. Identificação das Fontes

* 
**Origem Principal:** Ergast Developer API / Base de Dados Histórica de Formula 1 (ou repositórios equivalentes como Kaggle).


* 
**Dados Externos:** Dados meteorológicos históricos por localização de circuito (temperatura, precipitação).


* 
**Dados Financeiros:** Relatórios financeiros públicos auditados das equipas de F1 (Ferrari, Mercedes, Red Bull, etc.) e regulamento financeiro da FIA para orçamentos anuais.


* 
**Dados de Degradação de Pneus:** Telemetria histórica oficial da F1 e relatórios técnicos de degradação fornecidos pela Pirelli.



### 3.2. Estrutura do Modelo de Origem (OLTP)

As fontes de dados dividem-se em três categorias: **dados tabulares históricos** (CSV), **dados de telemetria e sessão** (JSON/CSV por época/corrida/sessão), e **dados de incidentes e segurança** (CSV).

#### 3.2.1. Dados Tabulares Históricos (ficheiros CSV na raiz de `project/data/`)

| Ficheiro | Descrição | Chave Primária |
|---|---|---|
| `circuits` | Circuitos do campeonato | `circuitId` |
| `constructor_results` | Resultados agregados por construtor/corrida | `constructorResultsId` |
| `constructor_standings` | Classificação de construtores por corrida | `constructorStandingsId` |
| `constructors` | Construtores/equipas | `constructorId` |
| `driver_standings` | Classificação de pilotos por corrida | `driverStandingsId` |
| `drivers` | Pilotos | `driverId` |
| `lap_times` | Tempos de cada volta (todos os pilotos) | Composta: `raceId`, `driverId`, `lap` |
| `pit_stops` | Paragens nas boxes | Composta: `raceId`, `driverId`, `stop` |
| `qualifying` | Resultados de qualificação | `qualifyId` |
| `races` | Corridas do campeonato | `raceId` |
| `results` | Resultados individuais de cada corrida | `resultId` |
| `seasons` | Épocas do campeonato | `year` |
| `sprint_results` | Resultados de corridas sprint | `resultId` |
| `status` | Estado de término da corrida | `statusId` |

#### 3.2.2. Dados de Incidentes e Segurança

| Ficheiro | Descrição |
|---|---|
| `fatal_accidents_drivers` | Acidentes fatais envolvendo pilotos |
| `fatal_accidents_marshalls` | Acidentes fatais envolvendo comissários de pista |
| `red_flags` | Registo de interrupções por bandeira vermelha |
| `safety_cars` | Registo de intervenções do Safety Car |
| `virtual_safety_car_estimates.json` | Estimativa de voltas sob VSC por Grande Prémio |

#### 3.2.3. Dados de Telemetria e Sessão (estrutura de diretórios `project/data/{ano}/{Grande Prémio}/{Sessão}/`)

Para cada sessão (Practice 1/2/3, Qualifying, Race, Pre-Season Testing), existe a seguinte estrutura:

- `corners.json` — Metadados das curvas do circuito
- `drivers.json` — Lista de pilotos participantes na sessão
- `rcm.json` — Race Control Messages (mensagens de direção de prova)
- `session_laptimes.json` — Tempos de volta de todos os pilotos na sessão
- `weather.json` — Condições meteorológicas durante a sessão
- Pastas por piloto (ex: `HAM/`, `VER/`, `LEC/`) — Telemetria individual do piloto

### 3.3. Metadados Detalhados das Fontes

#### `circuits`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `circuitId` | INTEGER | PK | NOT NULL | Identificador único do circuito |
| `circuitRef` | VARCHAR(50) | - | NOT NULL | Referência textual amigável |
| `name` | VARCHAR(100) | - | NOT NULL | Nome oficial do circuito |
| `location` | VARCHAR(100) | - | NULLABLE | Cidade/localização |
| `country` | VARCHAR(50) | - | NULLABLE | País |
| `lat` | DECIMAL(10,6) | - | NULLABLE | Latitude (coordenadas) |
| `lng` | DECIMAL(10,6) | - | NULLABLE | Longitude (coordenadas) |
| `alt` | INTEGER | - | NULLABLE | Altitude em metros |
| `url` | VARCHAR(255) | - | NULLABLE | URL da Wikipedia |

#### `constructor_results`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `constructorResultsId` | INTEGER | PK | NOT NULL | Identificador único do resultado agregado |
| `raceId` | INTEGER | FK → races.raceId | NOT NULL | Corrida associada |
| `constructorId` | INTEGER | FK → constructors.constructorId | NOT NULL | Construtor associado |
| `points` | DECIMAL(8,2) | - | NULLABLE | Pontos obtidos pelo construtor na corrida |
| `status` | VARCHAR(20) | - | NULLABLE | Estado (ex: "\N" se pontuou, "D" se desclassificado) |

#### `constructor_standings`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `constructorStandingsId` | INTEGER | PK | NOT NULL | Identificador único da posição no campeonato |
| `raceId` | INTEGER | FK → races.raceId | NOT NULL | Corrida associada |
| `constructorId` | INTEGER | FK → constructors.constructorId | NOT NULL | Construtor associado |
| `points` | DECIMAL(8,2) | - | NOT NULL | Pontos acumulados até à corrida |
| `position` | INTEGER | - | NULLABLE | Posição no campeonato |
| `positionText` | VARCHAR(10) | - | NULLABLE | Posição em formato texto |
| `wins` | INTEGER | - | NOT NULL | Número de vitórias até à corrida |

#### `constructors`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `constructorId` | INTEGER | PK | NOT NULL | Identificador único do construtor |
| `constructorRef` | VARCHAR(50) | - | NOT NULL | Referência textual amigável |
| `name` | VARCHAR(100) | - | NOT NULL | Nome oficial da equipa |
| `nationality` | VARCHAR(50) | - | NULLABLE | País de origem |
| `url` | VARCHAR(255) | - | NULLABLE | URL da Wikipedia |

#### `drivers`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `driverId` | INTEGER | PK | NOT NULL | Identificador único do piloto |
| `driverRef` | VARCHAR(50) | - | NOT NULL | Referência textual amigável |
| `number` | INTEGER | - | NULLABLE | Número do carro |
| `code` | VARCHAR(3) | - | NULLABLE | Código de 3 letras (ex: "HAM") |
| `forename` | VARCHAR(50) | - | NOT NULL | Primeiro nome |
| `surname` | VARCHAR(50) | - | NOT NULL | Apelido |
| `dob` | DATE | - | NULLABLE | Data de nascimento |
| `nationality` | VARCHAR(50) | - | NULLABLE | Nacionalidade |
| `url` | VARCHAR(255) | - | NULLABLE | URL da Wikipedia |

#### `driver_standings`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `driverStandingsId` | INTEGER | PK | NOT NULL | Identificador único da posição no campeonato |
| `raceId` | INTEGER | FK → races.raceId | NOT NULL | Corrida associada |
| `driverId` | INTEGER | FK → drivers.driverId | NOT NULL | Piloto associado |
| `points` | DECIMAL(8,2) | - | NOT NULL | Pontos acumulados até à corrida |
| `position` | INTEGER | - | NULLABLE | Posição no campeonato |
| `positionText` | VARCHAR(10) | - | NULLABLE | Posição em formato texto |
| `wins` | INTEGER | - | NOT NULL | Número de vitórias até à corrida |

#### `lap_times`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `raceId` | INTEGER | FK → races.raceId | NOT NULL | Corrida associada |
| `driverId` | INTEGER | FK → drivers.driverId | NOT NULL | Piloto associado |
| `lap` | INTEGER | - | NOT NULL | Número da volta |
| `position` | INTEGER | - | NOT NULL | Posição do piloto nessa volta |
| `time` | VARCHAR(20) | - | NULLABLE | Tempo da volta (formato mm:ss.ms) |
| `milliseconds` | INTEGER | - | NULLABLE | Tempo da volta em milissegundos |

#### `pit_stops`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `raceId` | INTEGER | FK → races.raceId | NOT NULL | Corrida associada |
| `driverId` | INTEGER | FK → drivers.driverId | NOT NULL | Piloto associado |
| `stop` | INTEGER | - | NOT NULL | Número sequencial da paragem |
| `lap` | INTEGER | - | NOT NULL | Volta em que ocorreu |
| `time` | TIME | - | NOT NULL | Hora da paragem |
| `duration` | DECIMAL(8,3) | - | NOT NULL | Duração em segundos |
| `milliseconds` | INTEGER | - | NOT NULL | Duração em milissegundos |

#### `qualifying`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `qualifyId` | INTEGER | PK | NOT NULL | Identificador único da sessão de qualificação |
| `raceId` | INTEGER | FK → races.raceId | NOT NULL | Corrida associada |
| `driverId` | INTEGER | FK → drivers.driverId | NOT NULL | Piloto associado |
| `constructorId` | INTEGER | FK → constructors.constructorId | NOT NULL | Construtor associado |
| `number` | INTEGER | - | NOT NULL | Número do carro |
| `position` | INTEGER | - | NOT NULL | Posição final de qualificação |
| `q1` | VARCHAR(20) | - | NULLABLE | Melhor tempo na sessão Q1 |
| `q2` | VARCHAR(20) | - | NULLABLE | Melhor tempo na sessão Q2 |
| `q3` | VARCHAR(20) | - | NULLABLE | Melhor tempo na sessão Q3 |

#### `races`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `raceId` | INTEGER | PK | NOT NULL | Identificador único da corrida |
| `year` | INTEGER | - | NOT NULL | Época |
| `round` | INTEGER | - | NOT NULL | Ronda da época |
| `circuitId` | INTEGER | FK → circuits.circuitId | NOT NULL | Circuito onde se realizou |
| `name` | VARCHAR(100) | - | NOT NULL | Nome do Grande Prémio |
| `date` | DATE | - | NOT NULL | Data da corrida |
| `time` | TIME | - | NULLABLE | Hora de início |
| `url` | VARCHAR(255) | - | NULLABLE | URL da Wikipedia |
| `fp1_date` | DATE | - | NULLABLE | Data do primeiro treino livre |
| `fp1_time` | TIME | - | NULLABLE | Hora do primeiro treino livre |
| `fp2_date` | DATE | - | NULLABLE | Data do segundo treino livre |
| `fp2_time` | TIME | - | NULLABLE | Hora do segundo treino livre |
| `fp3_date` | DATE | - | NULLABLE | Data do terceiro treino livre |
| `fp3_time` | TIME | - | NULLABLE | Hora do terceiro treino livre |
| `quali_date` | DATE | - | NULLABLE | Data da qualificação |
| `quali_time` | TIME | - | NULLABLE | Hora da qualificação |
| `sprint_date` | DATE | - | NULLABLE | Data da corrida sprint |
| `sprint_time` | TIME | - | NULLABLE | Hora da corrida sprint |

#### `results`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `resultId` | INTEGER | PK | NOT NULL | Identificador único do resultado |
| `raceId` | INTEGER | FK → races.raceId | NOT NULL | Corrida associada |
| `driverId` | INTEGER | FK → drivers.driverId | NOT NULL | Piloto associado |
| `constructorId` | INTEGER | FK → constructors.constructorId | NOT NULL | Construtor associado |
| `number` | INTEGER | - | NOT NULL | Número do carro |
| `grid` | INTEGER | - | NOT NULL | Posição de partida |
| `position` | INTEGER | - | NULLABLE | Posição final (NULL se não classificado) |
| `positionText` | VARCHAR(10) | - | NOT NULL | Posição em formato texto ("1", "R", "DNF", etc.) |
| `positionOrder` | INTEGER | - | NOT NULL | Ordem de classificação numérica |
| `points` | DECIMAL(8,2) | - | NOT NULL | Pontos conquistados |
| `laps` | INTEGER | - | NOT NULL | Número de voltas completadas |
| `time` | VARCHAR(30) | - | NULLABLE | Tempo total de corrida |
| `milliseconds` | INTEGER | - | NULLABLE | Tempo total em milissegundos |
| `fastestLap` | INTEGER | - | NULLABLE | Número da volta mais rápida |
| `rank` | INTEGER | - | NULLABLE | Classificação da volta mais rápida (1 = mais rápido) |
| `fastestLapTime` | VARCHAR(20) | - | NULLABLE | Tempo da volta mais rápida |
| `fastestLapSpeed` | DECIMAL(8,3) | - | NULLABLE | Velocidade média da volta mais rápida (km/h) |
| `statusId` | INTEGER | FK → status.statusId | NOT NULL | Estado de término (Finished, DNF, Collision, etc.) |

#### `seasons`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `year` | INTEGER | PK | NOT NULL | Ano da época |
| `url` | VARCHAR(255) | - | NULLABLE | URL da Wikipedia |

#### `sprint_results`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `resultId` | INTEGER | PK | NOT NULL | Identificador único do resultado sprint |
| `raceId` | INTEGER | FK → races.raceId | NOT NULL | Corrida associada |
| `driverId` | INTEGER | FK → drivers.driverId | NOT NULL | Piloto associado |
| `constructorId` | INTEGER | FK → constructors.constructorId | NOT NULL | Construtor associado |
| `number` | INTEGER | - | NOT NULL | Número do carro |
| `grid` | INTEGER | - | NOT NULL | Posição de partida |
| `position` | INTEGER | - | NULLABLE | Posição final |
| `positionText` | VARCHAR(10) | - | NOT NULL | Posição em formato texto |
| `positionOrder` | INTEGER | - | NOT NULL | Ordem de classificação numérica |
| `points` | DECIMAL(8,2) | - | NOT NULL | Pontos conquistados |
| `laps` | INTEGER | - | NOT NULL | Número de voltas |
| `time` | VARCHAR(30) | - | NULLABLE | Tempo total |
| `milliseconds` | INTEGER | - | NULLABLE | Tempo total em milissegundos |
| `fastestLap` | INTEGER | - | NULLABLE | Número da volta mais rápida |
| `fastestLapTime` | VARCHAR(20) | - | NULLABLE | Tempo da volta mais rápida |
| `statusId` | INTEGER | FK → status.statusId | NOT NULL | Estado de término |
| `rank` | INTEGER | - | NULLABLE | Classificação da volta mais rápida |

#### `status`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `statusId` | INTEGER | PK | NOT NULL | Identificador único do estado |
| `status` | VARCHAR(100) | - | NOT NULL | Descrição (ex: "Finished", "Disqualified", "Accident", "Collision", "+1 Lap") |

#### `safety_cars`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `Race` | VARCHAR(100) | - | NOT NULL | Nome do Grande Prémio |
| `Cause` | VARCHAR(100) | - | NOT NULL | Causa da intervenção (ex: "Accident", "Rain") |
| `Deployed` | INTEGER | - | NOT NULL | Volta em que o Safety Car foi acionado |
| `Retreated` | DECIMAL(5,1) | - | NULLABLE | Volta em que o Safety Car recolheu |
| `FullLaps` | INTEGER | - | NULLABLE | Número de voltas completas sob Safety Car |

#### `red_flags`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `Race` | VARCHAR(100) | - | NOT NULL | Nome do Grande Prémio |
| `Lap` | INTEGER | - | NOT NULL | Volta em que ocorreu a interrupção |
| `Resumed` | VARCHAR(5) | - | NOT NULL | "Y" se a corrida foi retomada, "N" se cancelada |
| `Incident` | TEXT | - | NULLABLE | Descrição do incidente |
| `Excluded` | TEXT | - | NULLABLE | Lista de pilotos ou entidades excluídas |

#### `fatal_accidents_drivers`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `Driver` | VARCHAR(100) | - | NOT NULL | Nome do piloto |
| `Age` | INTEGER | - | NOT NULL | Idade à data do acidente |
| `Date Of Accident` | DATE | - | NOT NULL | Data do acidente |
| `Event` | VARCHAR(100) | - | NOT NULL | Evento onde ocorreu o acidente |
| `Car` | VARCHAR(100) | - | NULLABLE | Construtor do carro |
| `Session` | VARCHAR(50) | - | NOT NULL | Sessão (Practice, Race, Test, etc.) |

#### `fatal_accidents_marshalls`

| Coluna | Tipo | Chave | Nulidade | Descrição |
|--------|------|-------|----------|----------|
| `Name` | VARCHAR(100) | - | NOT NULL | Nome do comissário |
| `Age` | INTEGER | - | NOT NULL | Idade à data do acidente |
| `Date Of Accident` | DATE | - | NOT NULL | Data do acidente |
| `Event` | VARCHAR(100) | - | NOT NULL | Evento onde ocorreu o acidente |

#### `virtual_safety_car_estimates.json`

| Campo | Tipo | Descrição |
|-------|------|----------|
| Chave | VARCHAR | Nome do Grande Prémio (ex: "2015 Belgian Grand Prix") |
| Valor | ARRAY[INTEGER] | Array de números de volta onde o VSC esteve estimativamente ativo |

---

4. Arquitetura de Dados e Data Warehouse 

### 4.1. 

Requisitos Mínimos do Modelo Dimensional 

* 
**Assunto de Análise:** Performance em Corrida (Mínimo de 1 assunto).


* 
**Medidas (Mínimo de 2):** Pontos Acumulados, Tempo Total em Pit Stops, Posições Ganhas.


* **Dimensões (Mínimo de 4):**
1. 
**Dimensão Tempo/Data:** Granularidade ao nível do dia (Obrigatório), organizada na hierarquia Ano -> Mês -> Dia.


2. **Dimensão Piloto:** Atributos (Nome, Equipa Atual, Nacionalidade, Idade).
3. 
**Dimensão Circuito:** Atributos organizados em hierarquia (Continente -> País -> Cidade -> Circuito).


4. **Dimensão Construtor:** Atributos (Nome, País, Motorizador).

**Diagrama do Modelo em Estrela (Star Schema):**

```
                        ┌──────────────────────┐
                        │     Dim_Tempo         │
                        │──────────────────────│
                        │ Data_SK (PK)          │
                        │ Ano                   │
                        │ Mes                   │
                        │ Dia                   │
                        └──────────┬───────────┘
                                   │
                        ┌──────────┴───────────┐
                        │   Fact_Performance    │
                        │──────────────────────│
                        │ Data_SK (FK)          │
                        │ Piloto_SK (FK)        │
                        │ Circuito_SK (FK)      │
                        │ Construtor_SK (FK)    │
                        │──────────────────────│
                        │ Pontos_Conquistados   │
                        │ Tempo_Total_Pit_Stops   │
                        │ Posicoes_Ganhas       │
                        │ Posicao_Partida       │
                        │ Posicao_Final         │
                        └──┬───────┬───────┬───┘
                           │       │       │
              ┌────────────┘       │       └────────────┐
              │                    │                    │
   ┌──────────┴───────────┐ ┌─────┴────────────┐ ┌─────┴────────────┐
   │     Dim_Piloto        │ │   Dim_Circuito   │ │  Dim_Construtor  │
   │──────────────────────│ │──────────────────│ │─────────────────│
   │ Piloto_SK (PK)       │ │ Circuito_SK (PK) │ │ Construtor_SK(PK)│
   │ Nome_Completo        │ │ Nome_Circuito    │ │ Nome             │
   │ Nacionalidade        │ │ Cidade           │ │ Pais             │
   │ Data_Nascimento      │ │ Pais             │ │ Motorizador      │
   │ Equipa_Atual         │ │ Continente       │ └──────────────────┘
   └──────────────────────┘ └──────────────────┘
```

### 4.2. 

Matriz de Mapeamento (Origem -> Destino) 

| Tabela Origem (OLTP) | Atributo Origem | Tipo Origem | Tabela Destino (DW) | Atributo Destino (DW) | Tipo Destino | Transformação / Regra de Negócio |
| --- | --- | --- | --- | --- | --- | --- |
| `races.date` | `date` | DATE | `Dim_Tempo` | `Data_SK` | INTEGER (SK) | Conversão de DATE para inteiro (YYYYMMDD) |
| `races.date` | `date` | DATE | `Dim_Tempo` | `Ano` | INTEGER | Extração do ano (YEAR) |
| `races.date` | `date` | DATE | `Dim_Tempo` | `Mes` | INTEGER | Extração do mês (MONTH) |
| `races.date` | `date` | DATE | `Dim_Tempo` | `Dia` | INTEGER | Extração do dia (DAY) |
| `results.raceId` + `races.date` | `raceId`, `date` | INTEGER, DATE | `Fact_Performance` | `Data_SK` | INTEGER (FK) | JOIN `results.raceId` = `races.id`; converter `races.date` para inteiro YYYYMMDD |
| `drivers.forename` + `surname` | `forename`, `surname` | VARCHAR(50) | `Dim_Piloto` | `Nome_Completo` | VARCHAR(101) | Concatenação: forename + ' ' + surname |
| `drivers.nationality` | `nationality` | VARCHAR(50) | `Dim_Piloto` | `Nacionalidade` | VARCHAR(50) | Mapeamento direto |
| `drivers.dob` | `dob` | DATE | `Dim_Piloto` | `Data_Nascimento` | DATE | Mapeamento direto |
| `results.constructorId` | `constructorId` | INTEGER | `Dim_Piloto` | `Equipa_Atual` | VARCHAR(50) | JOIN com `constructors.name`; SCD Tipo 2 se mudar de equipa |
| `circuits.name` | `name` | VARCHAR(100) | `Dim_Circuito` | `Nome_Circuito` | VARCHAR(100) | Mapeamento direto |
| `circuits.location` | `location` | VARCHAR(100) | `Dim_Circuito` | `Cidade` | VARCHAR(100) | Mapeamento direto |
| `circuits.country` | `country` | VARCHAR(50) | `Dim_Circuito` | `Pais` | VARCHAR(50) | Mapeamento direto |
| `circuits.country` | `country` | VARCHAR(50) | `Dim_Circuito` | `Continente` | VARCHAR(50) | Enriquecimento via tabela de lookup geográfica |
| `constructors.name` | `name` | VARCHAR(50) | `Dim_Construtor` | `Nome` | VARCHAR(50) | Mapeamento direto |
| `constructors.nationality` | `nationality` | VARCHAR(50) | `Dim_Construtor` | `Pais` | VARCHAR(50) | Mapeamento direto |
| `constructors.name` | `name` | VARCHAR(50) | `Dim_Construtor` | `Motorizador` | VARCHAR(50) | Enriquecimento via lookup (ex: Mercedes-AMG → Mercedes) |
| `results.points` | `points` | DECIMAL(8,2) | `Fact_Performance` | `Pontos_Conquistados` | DECIMAL(8,2) | Mapeamento direto |
| `pit_stops.duration` | `duration` | DECIMAL(8,3) | `Fact_Performance` | `Tempo_Total_Pit_Stops` | DECIMAL(8,3) | Soma da duração de todas as paragens do piloto na corrida |
| `results.position` | `position` | INTEGER | `Fact_Performance` | `Posicao_Final` | INTEGER | Mapeamento direto; NULL = "Não classificado" |
| `results.grid` | `grid` | INTEGER | `Fact_Performance` | `Posicao_Partida` | INTEGER | Mapeamento direto |
| `results.position` / `grid` | `position`, `grid` | INTEGER | `Fact_Performance` | `Posicoes_Ganhas` | INTEGER | Cálculo: `grid` - `position` (se position IS NULL então 0) |

---

5. Engenharia e Integração de Dados (ETL) 

### 5.1. Processo de Integração

* 
**Ferramenta ETL:** Python (pandas) para extração e transformação; SQL Server Integration Services (SSIS) para orquestração e carga; armazenamento em SQL Server / PostgreSQL.


* 
**Frequência:** Refrescamento incremental agendado nas 24h após cada Grande Prémio. A identificação de novos registos na origem baseia-se no campo `races.date` (corridas posteriores à última data carregada) e nos IDs incrementais de `races.id` e `results.id`.


* **Ferramentas de Visualização:** Power BI para construção de dashboards e análise ad-hoc.


* **Transformações Críticas:**
* Tratamento de valores nulos ou strings de texto indicando abandonos (ex: "R", "DNF") para codificação numérica padronizada na tabela de factos.
* **Gestão de SCD (Slowly Changing Dimensions):** A dimensão `Dim_Piloto` aplica SCD Tipo 2 no atributo `Equipa_Atual` para preservar o histórico de mudanças de equipa dos pilotos ao longo das épocas. As restantes dimensões seguem SCD Tipo 0 (atributos estáticos) ou SCD Tipo 1 (sobrescrita), conforme a natureza dos atributos.


* Cálculo derivado de métricas: `Posicao_Final` $-$ `Posicao_Partida` = `Posicoes_Ganhas`.


* **Controlo de Qualidade dos Dados:**
* Validação de integridade referencial entre factos e dimensões (verificação de chaves estrangeiras).
* Monitorização de duplicados nas tabelas de dimensões (por chave de negócio).
* Registo de métricas de qualidade (linhas carregadas, rejeitadas, transformers aplicados) para auditoria.



---

6. Análise, Visualização e Storytelling 

### 6.1. 

Painéis Analíticos (Dashboards) 

1. 
**Painel Executivo de Construtores:** KPIs de eficiência de pit stop, fiabilidade mecânica por motorizador e pontos por corrida.


2. **Painel de Performance do Piloto:** Telemetria simulada, consistência de voltas, e análise comparativa direta (*Head-to-Head*) entre companheiros de equipa.
3. **Painel de Análise de Circuitos:** Histórico de intervenções do Safety Car, taxa de ultrapassagens e impacto das condições climatéricas na estratégia de pneus.

### 6.2. 

Narrativa de Dados (Storytelling) 

* 
**Foco da Apresentação:** "A Anatomia de uma Vitória: Como os Dados Definem o Campeão do Mundo".


* 
**Fluxo Narrativo:** Partir macro (análise de regulamentos e orçamentos) -> intermédio (estratégia de corrida e paragens nas boxes) -> micro (decisões por volta em função do clima).



---

7. Critérios de Avaliação e Pesos 

| Componente de Avaliação | Peso | Foco de Validação Técnica 

 |
| --- | --- | --- |
| <br>**Conceção** 

 | 10% | Alinhamento dos objetivos com as 10+ questões de análise definidas.

 |
| <br>**Estudo das Fontes e Metadados** 

 | 10% | Mapeamento estruturado do modelo relacional original.

 |
| <br>**Modelo Dimensional** 

 | 15% | Correção das relações no esquema (estrela/floco de neve), hierarquias e dimensões obrigatórias.

 |
| <br>**Integração de Dados (ETL)** 

 | 20% | Robustez das pipelines de carga e qualidade da transformação dos dados operacionais.

 |
| <br>**Projeto de Análise de Dados** 

 | 20% | Profundidade analítica dos dashboards e utilidade prática dos KPIs criados.

 |
| <br>**Apresentação** 

 | 10% | Qualidade do suporte visual e clareza técnica na defesa.

 |
| <br>**Narração da História (Storytelling)** 

 | 10% | Capacidade de extrair insights de negócio do modelo construído durante a oral.

 |
| <br>**Relatório (Estrutura e Forma)** 

 | 5% | Rigor científico, clareza na documentação e justificações das decisões técnicas.

 |

---

## 8. Checklist de Validação Final para Entrega

Antes de submeter a proposta até 15 de maio, o grupo deve assegurar os seguintes pontos:

* [X] **Inscrição no Moodle:** O grupo (máximo 3 elementos) registou-se no formulário específico criado pelo docente?
* [ ] **Ferramentas:** Confirmou com o docente se o uso combinado de Python (ETL) e SQL Server/PostgreSQL corresponde ao ecossistema de software letivo abordado nas aulas práticas?
* [ ] **Formato do Relatório:** O relatório final em PDF está a ser estruturado utilizando o template oficial de conferências IEEE recomendado no enunciado?
* [ ] **Número de Questões:** O documento define pelo menos 10 questões de análise alinhadas com os objetivos de negócio?
* [ ] **Completude dos Metadados:** As tabelas de metadados (Secção 3.3) cobrem todas as colunas das fontes originais com tipos, chaves e descrições?
* [ ] **Integridade do Modelo Dimensional:** O star schema respeita a granularidade (1 linha por piloto por corrida) e todas as chaves estrangeiras estão corretamente mapeadas?
* [ ] **Estratégia de ETL:** O pipeline de refrescamento incremental e a gestão de SCD estão devidamente especificados?