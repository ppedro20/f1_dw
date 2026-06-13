# Dicionário de Dados — BD Operacional `f1_operacional`

Fonte: 18 ficheiros CSV originais, migrados para SQL Server via `0_preparacao/criar_bd_operacional.py`.  
Cobertura temporal: 1950 – 2026.

> **Legenda:** PO = Preenchimento Obrigatório | PK = Chave Primária | FK = Chave Estrangeira

---

## circuits
Circuitos onde se realizam as corridas de Fórmula 1.  
**Registos:** 78

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| circuitId | INT | Inteiro sequencial > 0 | Sim | PK |
| circuitRef | VARCHAR(20) | Identificador textual único (slug) | Sim | — |
| name | VARCHAR(100) | Nome oficial do circuito | Sim | — |
| location | VARCHAR(50) | Cidade / localidade | Sim | — |
| country | VARCHAR(50) | País | Sim | — |
| lat | DECIMAL(10,6) | Latitude em graus decimais | Sim | — |
| lng | DECIMAL(10,6) | Longitude em graus decimais | Sim | — |
| alt | INT | Altitude em metros | Sim | — |
| url | VARCHAR(200) | URL Wikipedia do circuito | Não | — |

---

## seasons
Épocas do Campeonato Mundial de Fórmula 1.  
**Registos:** 77

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| year | SMALLINT | 1950 – 2026 | Sim | PK |
| url | VARCHAR(150) | URL Wikipedia da época | Não | — |

---

## races
Corridas realizadas em cada época, por ordem de ronda.  
**Registos:** 1171

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| raceId | INT | Inteiro sequencial > 0 | Sim | PK |
| year | SMALLINT | 1950 – 2026 | Sim | FK → seasons.year |
| round | SMALLINT | Nº da ronda na época (1–24) | Sim | — |
| circuitId | INT | Referência ao circuito | Sim | FK → circuits.circuitId |
| name | VARCHAR(50) | Nome do Grande Prémio | Sim | — |
| date | DATE | Data de realização da corrida | Sim | — |
| time | VARCHAR(10) | Hora de início da corrida (HH:MM:SS) | Não | — |
| url | VARCHAR(150) | URL Wikipedia da corrida | Não | — |
| fp1_date | DATE | Data do Treino Livre 1 | Não | — |
| fp1_time | VARCHAR(10) | Hora do Treino Livre 1 | Não | — |
| fp2_date | DATE | Data do Treino Livre 2 | Não | — |
| fp2_time | VARCHAR(10) | Hora do Treino Livre 2 | Não | — |
| fp3_date | DATE | Data do Treino Livre 3 | Não | — |
| fp3_time | VARCHAR(10) | Hora do Treino Livre 3 | Não | — |
| quali_date | DATE | Data da Qualificação | Não | — |
| quali_time | VARCHAR(10) | Hora da Qualificação | Não | — |
| sprint_date | DATE | Data da Corrida Sprint (se existir) | Não | — |
| sprint_time | VARCHAR(10) | Hora da Corrida Sprint | Não | — |

---

## drivers
Pilotos que participaram em pelo menos uma corrida de F1.  
**Registos:** 865

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| driverId | INT | Inteiro sequencial > 0 | Sim | PK |
| driverRef | VARCHAR(25) | Identificador textual único (slug) | Sim | — |
| number | INT | Número permanente do piloto | Não | — |
| code | CHAR(3) | Código de 3 letras (ex: HAM) | Não | — |
| forename | VARCHAR(30) | Primeiro nome | Sim | — |
| surname | VARCHAR(30) | Apelido | Sim | — |
| dob | DATE | Data de nascimento | Sim | — |
| nationality | VARCHAR(20) | Nacionalidade | Sim | — |
| url | VARCHAR(200) | URL Wikipedia do piloto | Não | — |

---

## constructors
Equipas construtoras participantes no Campeonato de Construtores.  
**Registos:** 214

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| constructorId | INT | Inteiro sequencial > 0 | Sim | PK |
| constructorRef | VARCHAR(25) | Identificador textual único (slug) | Sim | — |
| name | VARCHAR(50) | Nome oficial da equipa | Sim | — |
| nationality | VARCHAR(20) | Nacionalidade da equipa | Sim | — |
| url | VARCHAR(200) | URL Wikipedia da equipa | Não | — |

---

## status
Códigos de estado que descrevem o resultado de chegada de um piloto.  
**Registos:** 140

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| statusId | INT | Inteiro sequencial > 0 | Sim | PK |
| status | VARCHAR(25) | Descrição (ex: Finished, Engine, Accident) | Sim | — |

---

## results
Resultado individual de cada piloto em cada corrida.  
**Registos:** 27 370

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| resultId | INT | Inteiro sequencial > 0 | Sim | PK |
| raceId | INT | Referência à corrida | Sim | FK → races.raceId |
| driverId | INT | Referência ao piloto | Sim | FK → drivers.driverId |
| constructorId | INT | Referência à equipa | Sim | FK → constructors.constructorId |
| number | SMALLINT | Número de corrida do piloto | Não | — |
| grid | SMALLINT | Posição de partida (grid) | Não | — |
| position | SMALLINT | Posição de chegada (NULL se não terminou) | Não | — |
| positionText | VARCHAR(5) | Posição textual (ex: 1, R, D, W, F, N) | Não | — |
| positionOrder | SMALLINT | Ordem de chegada para efeitos de classificação | Sim | — |
| points | DECIMAL(6,2) | Pontos obtidos na corrida | Sim | — |
| laps | SMALLINT | Número de voltas completadas | Sim | — |
| time | VARCHAR(20) | Tempo total de corrida ou diferença para líder | Não | — |
| milliseconds | INT | Tempo total em milissegundos | Não | — |
| fastestLap | SMALLINT | Número da volta em que fez a volta mais rápida | Não | — |
| rank | SMALLINT | Classificação da volta mais rápida na corrida | Não | — |
| fastestLapTime | VARCHAR(12) | Tempo da volta mais rápida (MM:SS.mmm) | Não | — |
| fastestLapSpeed | DECIMAL(6,3) | Velocidade média da volta mais rápida (km/h) | Não | — |
| statusId | INT | Referência ao estado de chegada | Sim | FK → status.statusId |

---

## driver_standings
Classificação do Campeonato de Pilotos após cada corrida.  
**Registos:** 35 493

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| driverStandingsId | INT | Inteiro sequencial > 0 | Sim | PK |
| raceId | INT | Referência à corrida (ponto de corte) | Sim | FK → races.raceId |
| driverId | INT | Referência ao piloto | Sim | FK → drivers.driverId |
| points | DECIMAL(8,2) | Pontos acumulados até esta corrida | Sim | — |
| position | INT | Posição na classificação geral | Não | — |
| positionText | VARCHAR(5) | Posição textual | Sim | — |
| wins | INT | Número de vitórias acumuladas | Sim | — |

---

## constructor_standings
Classificação do Campeonato de Construtores após cada corrida.  
**Registos:** 13 697

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| constructorStandingsId | INT | Inteiro sequencial > 0 | Sim | PK |
| raceId | INT | Referência à corrida (ponto de corte) | Sim | FK → races.raceId |
| constructorId | INT | Referência à equipa | Sim | FK → constructors.constructorId |
| points | DECIMAL(8,2) | Pontos acumulados até esta corrida | Sim | — |
| position | INT | Posição na classificação geral | Não | — |
| positionText | VARCHAR(5) | Posição textual | Sim | — |
| wins | INT | Número de vitórias acumuladas | Sim | — |

---

## constructor_results
Pontos obtidos por cada equipa em cada corrida.  
**Registos:** 12 931

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| constructorResultsId | INT | Inteiro sequencial > 0 | Sim | PK |
| raceId | INT | Referência à corrida | Sim | FK → races.raceId |
| constructorId | INT | Referência à equipa | Sim | FK → constructors.constructorId |
| points | DECIMAL(6,2) | Pontos obtidos na corrida | Sim | — |
| status | VARCHAR(5) | Indicador de desqualificação (D) ou normal (NULL) | Não | — |

---

## qualifying
Resultados das sessões de qualificação (Q1, Q2, Q3).  
**Registos:** 11 102

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| qualifyId | INT | Inteiro sequencial > 0 | Sim | PK |
| raceId | INT | Referência à corrida | Sim | FK → races.raceId |
| driverId | INT | Referência ao piloto | Sim | FK → drivers.driverId |
| constructorId | INT | Referência à equipa | Sim | FK → constructors.constructorId |
| number | SMALLINT | Número de corrida do piloto | Sim | — |
| position | SMALLINT | Posição final na qualificação | Sim | — |
| q1 | VARCHAR(12) | Tempo na sessão Q1 (MM:SS.mmm) | Não | — |
| q2 | VARCHAR(12) | Tempo na sessão Q2 (MM:SS.mmm) | Não | — |
| q3 | VARCHAR(12) | Tempo na sessão Q3 (MM:SS.mmm) | Não | — |

---

## sprint_results
Resultados das corridas sprint (formato introduzido em 2021).  
**Registos:** 546

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| resultId | INT | Inteiro sequencial > 0 | Sim | PK |
| raceId | INT | Referência ao fim de semana de corrida | Sim | FK → races.raceId |
| driverId | INT | Referência ao piloto | Sim | FK → drivers.driverId |
| constructorId | INT | Referência à equipa | Sim | FK → constructors.constructorId |
| number | SMALLINT | Número de corrida do piloto | Sim | — |
| grid | SMALLINT | Posição de partida na sprint | Sim | — |
| position | SMALLINT | Posição de chegada (NULL se não terminou) | Não | — |
| positionText | VARCHAR(5) | Posição textual | Não | — |
| positionOrder | SMALLINT | Ordem de chegada para classificação | Sim | — |
| points | SMALLINT | Pontos obtidos na sprint | Sim | — |
| laps | SMALLINT | Número de voltas completadas | Sim | — |
| time | VARCHAR(20) | Tempo total ou diferença para líder | Não | — |
| milliseconds | INT | Tempo total em milissegundos | Não | — |
| fastestLap | SMALLINT | Número da volta mais rápida | Não | — |
| fastestLapTime | VARCHAR(12) | Tempo da volta mais rápida | Não | — |
| statusId | SMALLINT | Referência ao estado de chegada | Não | FK → status.statusId |
| rank | SMALLINT | Classificação da volta mais rápida | Não | — |

---

## lap_times
Tempo de cada volta de cada piloto em cada corrida.  
**Registos:** 872 521 (disponível a partir de 1996)

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| raceId | INT | Referência à corrida | Sim | FK → races.raceId |
| driverId | INT | Referência ao piloto | Sim | FK → drivers.driverId |
| lap | SMALLINT | Número da volta | Sim | — |
| position | SMALLINT | Posição em pista nessa volta | Sim | — |
| time | VARCHAR(15) | Tempo da volta (M:SS.mmm) | Sim | — |
| milliseconds | INT | Tempo da volta em milissegundos | Sim | — |

---

## pit_stops
Registo de cada paragem em pit stop durante uma corrida.  
**Registos:** 22 335 (disponível a partir de 2011)

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| raceId | INT | Referência à corrida | Sim | FK → races.raceId |
| driverId | INT | Referência ao piloto | Sim | FK → drivers.driverId |
| stop | SMALLINT | Número sequencial da paragem (1ª, 2ª, ...) | Sim | — |
| lap | SMALLINT | Volta em que ocorreu a paragem | Sim | — |
| time | VARCHAR(10) | Hora do dia em que ocorreu (HH:MM:SS) | Sim | — |
| duration | VARCHAR(15) | Duração da paragem (segundos.milissegundos) | Não | — |
| milliseconds | INT | Duração da paragem em milissegundos | Não | — |

---

## safety_cars
Deployments do Safety Car durante corridas.  
**Registos:** 370 (a partir de 1973)

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| Race | VARCHAR(50) | Nome e ano da corrida | Sim | — |
| Cause | VARCHAR(30) | Causa do deployment (ex: Accident, Rain, Debris) | Sim | — |
| Deployed | SMALLINT | Volta em que o Safety Car foi acionado | Sim | — |
| Retreated | SMALLINT | Volta em que o Safety Car recolheu | Não | — |
| FullLaps | SMALLINT | Número de voltas completas sob Safety Car | Sim | — |

---

## red_flags
Bandeiras vermelhas que interromperam corridas.  
**Registos:** 99

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| Race | VARCHAR(50) | Nome e ano da corrida | Sim | — |
| Lap | SMALLINT | Volta em que foi exibida a bandeira vermelha | Sim | — |
| Resumed | VARCHAR(5) | Corrida retomada? (Y/N/R/S) | Não | — |
| Incident | VARCHAR(500) | Descrição do incidente que causou a bandeira | Sim | — |
| Excluded | VARCHAR(500) | Pilotos excluídos após o incidente | Não | — |

---

## fatal_accidents_drivers
Acidentes fatais com pilotos de Fórmula 1.  
**Registos:** 51

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| Driver | VARCHAR(50) | Nome do piloto | Sim | — |
| Age | INT | Idade no momento do acidente | Não | — |
| Date Of Accident | VARCHAR(15) | Data do acidente (formato variável) | Sim | — |
| Event | VARCHAR(60) | Nome do evento / Grande Prémio | Não | — |
| Car | VARCHAR(30) | Carro / chassi envolvido | Sim | — |
| Session | VARCHAR(20) | Sessão (Race, Practice, Test, Qualifying) | Sim | — |

---

## fatal_accidents_marshalls
Acidentes fatais com comissários de pista.  
**Registos:** 5

| Coluna | Tipo SQL | Domínio | PO | Chave |
|---|---|---|---|---|
| Name | VARCHAR(50) | Nome do comissário | Sim | — |
| Age | INT | Idade no momento do acidente | Sim | — |
| Date Of Accident | VARCHAR(15) | Data do acidente | Sim | — |
| Event | VARCHAR(60) | Nome do evento / Grande Prémio | Sim | — |
