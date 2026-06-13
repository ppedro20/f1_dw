# Regras de Negócio — BD Operacional `f1_operacional`

Descrição das relações e restrições que complementam o modelo ERD.

---

## Estrutura geral

A BD `f1_operacional` organiza-se em torno de três conceitos centrais: **corridas**, **pilotos** e **equipas**. Uma corrida realiza-se num circuito, numa determinada data de uma época. Cada piloto participa numa corrida ao serviço de uma equipa, e o resultado dessa participação fica registado em `results`.

---

## Relações principais

**Corrida → Circuito**
Cada corrida (`races`) realiza-se num e um só circuito (`circuits`). Um circuito pode acolher múltiplas corridas ao longo da história (ex: Monza, 76 corridas).

**Corrida → Época**
Cada corrida pertence a uma época (`seasons`) identificada pelo ano. Uma época tem entre 7 (1955) e 24 (2024) corridas.

**Resultado → Corrida + Piloto + Equipa**
Cada linha de `results` regista o desempenho de um piloto ao serviço de uma equipa numa corrida. Um piloto pode mudar de equipa entre corridas da mesma época.

**Resultado → Status**
O estado de chegada (`status`) classifica o resultado: `Finished` significa que completou a distância; qualquer outro valor indica abandono, desqualificação ou não participação.

**Classificações → Corrida (snapshot)**
As tabelas `driver_standings` e `constructor_standings` são snapshots acumulados após cada corrida — não representam o estado final da época, mas a posição em cada momento do campeonato. O campeão é o piloto/equipa em posição 1 na última corrida da época.

---

## Regras específicas por tabela

**`results.position`**
É NULL quando o piloto não terminou a corrida (abandono, desqualificação, não qualificação). Usar `positionOrder` para ordenação — inclui todos os participantes independentemente de terem terminado.

**`results.positionText`**
Codifica situações especiais: `R` = Retired, `D` = Disqualified, `W` = Withdrew, `F` = Failed to qualify, `N` = Not classified, `E` = Excluded.

**`constructor_results.status`**
Valor `D` indica desqualificação da equipa nessa corrida. NULL é o valor normal.

**`qualifying.q2` e `qualifying.q3`**
São NULL quando o piloto não passou à sessão seguinte. Apenas os 15 melhores do Q1 avançam para Q2; apenas os 10 melhores do Q2 avançam para Q3.

**`lap_times`**
Dados disponíveis apenas a partir de 1996. Antes disso a tabela não tem registos para as corridas históricas.

**`pit_stops`**
Dados disponíveis apenas a partir de 2011. A duração (`duration`) está em formato decimal de segundos (ex: `23.456`); `milliseconds` é a representação inteira equivalente. Existem 3 registos com duração NULL por erro de captura de dados.

**`safety_cars` e `red_flags`**
Estas tabelas não têm chave estrangeira formal para `races` — a ligação faz-se pelo nome textual da corrida (`Race`). No ETL será necessário fazer o match por nome + ano para associar ao `raceId`.

**`fatal_accidents_drivers`**
A coluna `Date Of Accident` está em formato americano variável (`M/D/YY`), não em formato ISO. Requer transformação no ETL. Existem 7 registos sem nome de evento (corridas de teste sem denominação oficial).

**`sprint_results`**
Introduzido em 2021. O `raceId` referencia o fim de semana completo (`races`), não uma entrada separada para a sprint. Ou seja, o mesmo `raceId` tem dados em `results` (corrida principal) e em `sprint_results` (sprint).

---

## Cobertura temporal por tabela

| Tabela | Início | Cobertura |
|---|---|---|
| races, results, driver_standings | 1950 | Completa |
| constructor_standings | 1958 | A partir do 1º Campeonato de Construtores |
| qualifying | 1994 | A partir do formato Q moderno |
| lap_times | 1996 | Dados electrónicos disponíveis |
| pit_stops | 2011 | Dados oficiais FOM disponíveis |
| sprint_results | 2021 | Formato sprint introduzido |
| safety_cars | 1973 | Primeiro safety car na F1 |
