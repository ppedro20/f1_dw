# Perguntas de Análise — F1 Data Warehouse

O sistema analítico deve ser capaz de responder às seguintes questões.  
Cada pergunta está mapeada para as tabelas de origem, dimensões e medidas do DW.

---

## Q01 — Quem dominou a Fórmula 1?
*Quais os pilotos com mais vitórias e campeonatos ao longo da história?*

| | |
|---|---|
| **Tabelas OLTP** | results, driver_standings, drivers, races |
| **Dimensões DW** | dim_piloto, dim_data, dim_corrida |
| **Medidas** | nº de vitórias, nº de campeonatos, pontos totais |
| **Hierarquia** | dim_data → ano → época |
| **Facto EDA** | Hamilton (105 vitórias, 7 títulos), Schumacher (91 vitórias, 7 títulos) |
| **Visual** | Bar chart horizontal com filtro por era |

---

## Q02 — A pole position garante a vitória?
*Qual a taxa de conversão entre pole position e vitória, e como varia por circuito?*

| | |
|---|---|
| **Tabelas OLTP** | qualifying, results, circuits, races |
| **Dimensões DW** | dim_circuito, dim_piloto, dim_data |
| **Medidas** | nº de poles, nº de vitórias desde a pole, taxa de conversão (%) |
| **Facto EDA** | 43,1% das corridas são ganhas a partir da pole |
| **Visual** | KPI card + bar chart por circuito |

---

## Q03 — Os carros ficaram mais fiáveis?
*Como evoluiu a taxa de abandonos por causa mecânica ao longo das décadas?*

| | |
|---|---|
| **Tabelas OLTP** | results, status, races |
| **Dimensões DW** | dim_estado, dim_data, dim_construtor |
| **Medidas** | nº de DNFs, taxa de DNF (%), split mecânico vs. acidente |
| **Hierarquia** | dim_data → ano → década |
| **Facto EDA** | Taxa de DNF: 61% nos anos 80 → 15% na década de 2020 |
| **Visual** | Área chart por década com breakdown por categoria de DNF |

---

## Q04 — Os boxes ficaram mais rápidos?
*Como evoluiu o tempo médio de paragem em pit stop ao longo dos anos?*

| | |
|---|---|
| **Tabelas OLTP** | pit_stops, races |
| **Dimensões DW** | dim_data, dim_construtor, dim_corrida |
| **Medidas** | duração mediana do pit stop (ms), nº de paragens por corrida |
| **Facto EDA** | De ~31 segundos em 1994 para ~23 segundos na era moderna |
| **Visual** | Linha temporal com marcações de mudanças de regulamento |

---

## Q05 — Qual o circuito mais histórico?
*Quais os circuitos com mais corridas realizadas e maior longevidade no calendário?*

| | |
|---|---|
| **Tabelas OLTP** | circuits, races |
| **Dimensões DW** | dim_circuito, dim_data |
| **Medidas** | nº de corridas realizadas, nº de anos no calendário |
| **Hierarquia** | dim_circuito → continente → país → circuito |
| **Facto EDA** | Monza (76), Mónaco (72), Silverstone (61) |
| **Visual** | Mapa geográfico + bar chart |

---

## Q06 — As corridas ficaram mais caóticas?
*Como evoluiu a utilização do safety car e das bandeiras vermelhas ao longo do tempo?*

| | |
|---|---|
| **Tabelas OLTP** | safety_cars, red_flags, races |
| **Dimensões DW** | dim_data, dim_corrida, dim_circuito |
| **Medidas** | nº de deployments de SC, nº de bandeiras vermelhas, nº de voltas sob SC |
| **Facto EDA** | 370 safety cars totais; 51% por acidentes; 99 bandeiras vermelhas |
| **Visual** | Dual-axis bar + linha por ano |

---

## Q07 — A Fórmula 1 ficou mais segura?
*Quantos acidentes fatais ocorreram por década e qual o impacto das mudanças de regulamento?*

| | |
|---|---|
| **Tabelas OLTP** | fatal_accidents_drivers, fatal_accidents_marshalls |
| **Dimensões DW** | dim_data, dim_circuito |
| **Medidas** | nº de fatalidades (pilotos + comissários), por tipo de sessão |
| **Hierarquia** | dim_data → ano → década |
| **Facto EDA** | Concentração nos anos 70–80; quase zero após Senna (1994) |
| **Visual** | Timeline com anotações de marcos de segurança (FIA, HANS, Halo) |

---

## Q08 — O grid de partida prediz o resultado?
*Qual a correlação entre posição de partida e posição final na corrida?*

| | |
|---|---|
| **Tabelas OLTP** | results, races |
| **Dimensões DW** | dim_piloto, dim_corrida, dim_data |
| **Medidas** | posição no grid, posição final, posições ganhas/perdidas |
| **Facto EDA** | Correlação de 0,63 — forte mas não determinista; média de +3 posições ganhas |
| **Visual** | Scatter plot grid vs. resultado |

---

## Q09 — Que construtores dominaram cada era?
*Quais as equipas com mais Campeonatos de Construtores e como se distribuem por período?*

| | |
|---|---|
| **Tabelas OLTP** | constructor_standings, constructors, races |
| **Dimensões DW** | dim_construtor, dim_data |
| **Medidas** | nº de campeonatos, nº de vitórias, pontos por época |
| **Hierarquia** | dim_data → era/década; dim_construtor → país → equipa |
| **Facto EDA** | Ferrari (16), McLaren (10), Williams (9), Mercedes (9), Red Bull (6) |
| **Visual** | Bar chart empilhado por era |

---

## Q10 — O formato sprint veio para ficar?
*Como cresceu o número de corridas sprint e que impacto tem na classificação final?*

| | |
|---|---|
| **Tabelas OLTP** | sprint_results, races, driver_standings, constructor_standings |
| **Dimensões DW** | dim_data, dim_piloto, dim_construtor, dim_corrida |
| **Medidas** | nº de sprints por época, pontos obtidos em sprints, % de pontos totais via sprint |
| **Facto EDA** | 3 sprints em 2021 → 6 em 2023–2025 |
| **Visual** | Bar chart por ano + tabela de impacto nos campeonatos |

---

## Q11 — Há vantagem em correr em casa?
*A taxa de vitórias é maior quando o piloto corre no país da sua nacionalidade?*

| | |
|---|---|
| **Tabelas OLTP** | results, drivers, circuits, races |
| **Dimensões DW** | dim_piloto, dim_circuito, dim_corrida |
| **Medidas** | nº de vitórias em casa, nº fora, taxa de vitória em casa (%) |
| **Visual** | KPI comparativo casa vs. fora |

---

## Q12 — O calendário cresceu demasiado?
*Como evoluiu o número de corridas por época desde 1950?*

| | |
|---|---|
| **Tabelas OLTP** | races, seasons |
| **Dimensões DW** | dim_data, dim_corrida, dim_circuito |
| **Medidas** | nº de corridas por época, nº de países visitados, nº de continentes |
| **Facto EDA** | De ~8 corridas em 1950 para 24 em 2024 |
| **Visual** | Linha temporal + mapa de calor geográfico |

---

## Cobertura dos requisitos mínimos

| Requisito do enunciado | Estado |
|---|---|
| ≥ 10 questões de análise | ✅ 12 questões |
| Dimensão Data com detalhe diário | ✅ todas as questões usam dim_data |
| ≥ 1 assunto com 2 medidas | ✅ Q03 (nº DNFs + taxa DNF), Q04 (duração + nº paragens), Q09 (campeonatos + vitórias) |
| ≥ 4 dimensões, 2 com hierarquias | ✅ 6 dimensões; dim_data e dim_circuito com hierarquia |
