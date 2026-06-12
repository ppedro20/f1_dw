# Especificação de Dashboards

## Mapeamento Perguntas → Dashboards

| # | Pergunta | Dashboard |
|---|----------|-----------|
| 1 | Evolução histórica do tempo médio de pit stop por construtor | Painel Executivo de Construtores |
| 2 | Correlação entre pole position e vitória em circuitos de diferente altitude | Painel de Análise de Circuitos |
| 3 | Construtores com maior taxa de abandono por falha mecânica em temperatura elevada | Painel Executivo de Construtores |
| 4 | Consistência de tempos por volta ao transitar de pneus macios para duros | Painel de Performance do Piloto |
| 5 | Impacto do Safety Car na alteração das posições finais do Top 10 | Painel de Análise de Circuitos |
| 6 | Setor da volta com mais ultrapassagens em cada circuito | Painel de Análise de Circuitos |
| 7 | Distribuição geográfica dos pontos por nacionalidade (últimos 20 anos) | Painel Executivo de Construtores |
| 8 | Pilotos com maior ganho líquido de posições na 1.ª volta (P10-P15) | Painel de Performance do Piloto |
| 9 | Eficácia de undercut vs overcut com base no desgaste real dos pneus | Painel de Análise de Circuitos |
| 10 | Impacto do número de paragens (2 vs 3 stops) na posição final | Painel Executivo de Construtores |

---

## Dashboard 1 — Painel Executivo de Construtores

**Objetivo:** Visão macro da performance das equipas ao longo das épocas.

### Perguntas respondidas: 1, 3, 7, 10

### Visualizações e KPIs

| Elemento | Tipo Visual | Pergunta | Dados Necessários |
|----------|-------------|----------|-------------------|
| Evolução do tempo médio de pit stop por construtor (por época) | **Gráfico de linhas** (múltiplas séries) | Q1 | `pit_stops.duration`, `races.year`, `constructors.name` |
| *Ranking* atual de tempo médio de pit stop | **Tabela** com *ranking* | Q1 | Média de `pit_stops.duration` agrupado por construtor |
| Taxa de abandono por falha mecânica vs temperatura do circuito | **Gráfico de dispersão** (bubble chart) | Q3 | `results.statusId` → `status` ("Engine", "Gearbox", etc.), dados meteorológicos (temperatura), `constructors.name` |
| *Top* construtores com mais falhas mecânicas em calor extremo | **Barra horizontal** | Q3 | Filtro temperatura > 35°C, contagem de DNFs mecânicos por construtor |
| Mapa de pontos por nacionalidade do construtor | **Mapa coroplético** ou **mapa de bolhas** | Q7 | `results.points`, `constructors.nationality`, `races.year` (filtro últimos 20 anos) |
| Distribuição de pontos por construtor (últimos 20 anos) | **Barra empilhada** (ano a ano) | Q7 | `results.points`, `constructors.name`, `races.year` |
| Posição final média vs número de paragens (2 stops vs 3 stops) | **Gráfico de colunas agrupadas** | Q10 | `pit_stops.stop` (contagem), `results.positionOrder`, `results.constructorId` |
| Comparação de estratégias de paragens por construtor | **Matriz** ou **tabela dinâmica** | Q10 | Contagem de paragens, posição final, construtor |

### Filtros Globais do Dashboard
- Época (ano) — *range slider* ou *dropdown*
- Construtor — *dropdown* multi-select
- Tipo de motorizador — *segmentação*

---

## Dashboard 2 — Painel de Performance do Piloto

**Objetivo:** Análise detalhada da performance individual e comparação direta entre companheiros de equipa.

### Perguntas respondidas: 4, 8

### Visualizações e KPIs

| Elemento | Tipo Visual | Pergunta | Dados Necessários |
|----------|-------------|----------|-------------------|
| Variação do tempo por volta antes e após troca de pneus (macio → duro) | **Gráfico de linhas** com marcador de *pit stop* | Q4 | `lap_times.milliseconds`, `pit_stops.lap`, dados de composto de pneu (telemetria/sessão) |
| *Box plot* da distribuição de tempos por volta (macio vs duro) | **Box plot** | Q4 | `lap_times.milliseconds` segmentado por composto de pneu |
| Ganho líquido de posições na 1.ª volta (pilotos P10-P15) | **Barra horizontal** (ordenada) | Q8 | `results.grid`, posição após volta 1 (via `lap_times.position` na lap 1), diferença = grid - pos_lap1 |
| *Timeline* de posições na 1.ª volta por corrida | **Gráfico de bolhas** ou *strip plot* | Q8 | Grid, posição após volta 1, piloto, corrida |
| Comparação *head-to-head* entre companheiros de equipa | **Gráfico de radar** ou *dual axis* | 4, 8 | Médias de tempos por volta, posições ganhas, consistência (desvio padrão), pontos |
| Consistência de voltas (desvio padrão do tempo por volta) | **Gauge** + **tabela de ranking** | 4 | `lap_times.milliseconds`, desvio padrão por piloto/corrida |
| Evolução da performance ao longo da corrida (telemetria simulada) | **Gráfico de linhas** (velocidade / tempo por volta) | 4 | `lap_times.milliseconds` ou dados de telemetria por sessão |

### Filtros Globais do Dashboard
- Piloto — *dropdown*
- Equipa — *dropdown*
- Época — *dropdown*
- Corrida específica — *dropdown*

---

## Dashboard 3 — Painel de Análise de Circuitos

**Objetivo:** Caracterização dos circuitos e seu impacto na estratégia de corrida.

### Perguntas respondidas: 2, 5, 6, 9

### Visualizações e KPIs

| Elemento | Tipo Visual | Pergunta | Dados Necessários |
|----------|-------------|----------|-------------------|
| Taxa de conversão de *pole position* em vitória por circuito (com altitude) | **Gráfico de dispersão** (eixo X = altitude, Y = taxa de conversão, bolha = n.º de corridas) | Q2 | `qualifying.position` = 1, `results.position` = 1, `circuits.alt` |
| *Heatmap* de pole position vs vencedor por circuito | **Matriz de calor** | Q2 | Posição de qualificação vs posição final, segmentado por circuito |
| Frequência de intervenções de Safety Car por circuito | **Barra vertical** | Q5 | `safety_cars.Race`, `races.circuitId` |
| Alteração média de posições no Top 10 após Safety Car | **Gráfico de *slope*** (posição antes vs depois do SC) | Q5 | `safety_cars.Deployed`, `lap_times.position` antes/depois da volta do SC, `results` |
| Setor predominante de ultrapassagens por circuito (S1, S2, S3) | **Gráfico de barras empilhadas** (ou *heatmap* por setor) | Q6 | Dados de telemetria setoriais (corners.json + `rcm.json` / posições por setor) |
| Mapa do circuito com zonas de ultrapassagem mais frequentes | **Imagem de circuito** com *overlay* de calor | Q6 | Coordenadas de setores + contagem de ultrapassagens |
| Eficácia de undercut vs overcut | **Gráfico de comparação** (posição ganha/perdida por estratégia) | Q9 | `pit_stops.lap`, `lap_times.milliseconds` antes/depois, diferença de posição |
| Impacto do desgaste de pneus na estratégia (por condição climatérica) | **Gráfico de linhas** (n.º de voltas vs tempo, separado por seco/molhado) | Q9 | Dados meteorológicos (`weather.json`), `lap_times.milliseconds`, `pit_stops.lap` |

### Filtros Globais do Dashboard
- Circuito — *dropdown*
- Época — *range slider*
- Condição climatérica — *segmentação* (Seco / Molhado / Intermédio)

---

## Matriz de Consistência — Dimensões vs Dashboards

| Dimensão | Dashboard 1 | Dashboard 2 | Dashboard 3 |
|----------|:-----------:|:-----------:|:-----------:|
| Dim_Tempo (Ano/Mês/Dia) | ✓ | ✓ | ✓ |
| Dim_Piloto | | ✓ | |
| Dim_Circuito | | | ✓ |
| Dim_Construtor | ✓ | | |
| Fact_Performance (Pontos/Pit Stops/Posições) | ✓ | ✓ | ✓ |
| Dados Segurança (Safety Car) | | | ✓ |
| Dados Telemetria (Lap Times) | | ✓ | ✓ |
| Dados Climatéricos | | | ✓ |
| Dados Pneus | | ✓ | ✓ |
