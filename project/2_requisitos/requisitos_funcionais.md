# Requisitos Funcionais — F1 Data Warehouse

| # | Designação | Descrição | Prioridade | US |
|---|---|---|---|---|
| RF-01 | Performance histórica de pilotos | O sistema deve permitir identificar os pilotos com mais vitórias, poles e campeonatos, com filtragem por período histórico (ano, década) | ELEVADA | US01 |
| RF-02 | Eficácia da qualificação | O sistema deve permitir calcular a taxa de conversão pole → vitória e a evolução de posições entre grid e resultado final, por circuito e por piloto | ELEVADA | US02, US06 |
| RF-03 | Domínio de construtores por era | O sistema deve permitir visualizar campeonatos e vitórias por equipa ao longo do tempo, com drill-down por época | ELEVADA | US03 |
| RF-04 | Evolução dos pit stops | O sistema deve permitir visualizar a duração média dos pit stops por equipa e por ano, com identificação de evolução temporal | ELEVADA | US04 |
| RF-05 | Causas de abandono (DNF) | O sistema deve permitir identificar as principais causas de abandono por construtor, piloto e época, com cálculo da taxa de DNF | ELEVADA | US05 |
| RF-06 | Safety cars e bandeiras vermelhas | O sistema deve permitir visualizar o número e as causas de intervenções de safety car e bandeiras vermelhas por corrida, circuito e ano | MÉDIA | US07 |
| RF-07 | Evolução da segurança | O sistema deve permitir visualizar o número de acidentes fatais por década e por tipo de sessão | ELEVADA | US08 |
| RF-08 | Crescimento do calendário | O sistema deve permitir visualizar a evolução do número de corridas por época e a distribuição geográfica dos circuitos | MÉDIA | US09 |
| RF-09 | Impacto do formato sprint | O sistema deve permitir comparar a distribuição de pontos em épocas com e sem corridas sprint | MÉDIA | US10 |
| RF-10 | Fator casa | O sistema deve permitir comparar a taxa de vitórias dos pilotos no seu país natal vs. outras localizações | BAIXA | US11 |
| RF-11 | Navegação temporal multi-nível | O sistema deve suportar drill-down e drill-up na dimensão temporal (ano → semestre → trimestre → mês → semana → dia) e na dimensão geográfica (continente → país → circuito) | ELEVADA | Todas |
| RF-12 | Detalhe diário por corrida | O sistema deve manter os dados de cada corrida com detalhe ao nível do dia, incluindo posição de partida, posição final, pontos, voltas completadas e causa de abandono | ELEVADA | US02, US06 |
