# Narrativa de Dados — A Anatomia de uma Vitória

## 1. Conceito Central

A história que os dados contam é a de como uma vitória na Formula 1 não é um evento isolado, mas o resultado de decisões incrementais ao longo de um fim de semana de corrida — e de uma época inteira. Esta narrativa decompõe a vitória em três camadas:

1. **Macro** — A época como um todo: construtores, pilotos e classificação
2. **Meso** — O Grande Prémio: estratégia de corrida, paragens nas boxes e Safety Car
3. **Micro** — A volta: degradação de pneus, consistência e setores

---

## 2. Ato I — O Campeonato: Hegemonias e Tendências Globais

> *"Os pontos contam a história de quem dominou cada época."*

### 2.1. A Geografia dos Pontos

Os dados de resultados cruzados com a nacionalidade dos pilotos revelam hegemonias regionais ao longo das últimas duas décadas. Pilotos britânicos, alemães e finlandeses dominaram diferentes eras, refletindo ciclos de investimento nacional no desporto motorizado e a qualidade dos programas de formação de pilotos em cada país.

**Pergunta de análise:** *Qual é a distribuição geográfica dos pontos conquistados por nacionalidade de pilotos nos últimos 20 anos?*

### 2.2. A Classificação de Construtores

Os dados de classificação de construtores por época mostram ciclos de domínio — Ferrari nos anos 2000, Red Bull nos anos 2010, Mercedes na era híbrida. Cada mudança no topo do campeonato coincide com transições regulamentares ou técnicas, visíveis na evolução dos pontos acumulados ronda a ronda.

---

## 3. Ato II — O Grande Prémio: Estratégia e Execução

> *"A corrida ganha-se nas boxes, não apenas na pista."*

### 3.1. A Qualificação: A Pole Position Importa?

Os dados de qualificação vs. resultados finais contam uma história matizada. Em circuitos de alta altitude (como México ou Brasil), a vantagem aerodinâmica é diferente; a correlação pole→vitória varia significativamente por tipo de circuito.

**Pergunta de análise:** *Existe correlação direta entre a posição de qualificação e a vitória final em circuitos de diferente altitude?*

### 3.2. A Dança das Paragens

Cada milissegundo numa paragem nas boxes conta. A evolução histórica dos tempos de pit stop mostra uma melhoria dramática — de 12 segundos nos anos 90 para sub-2 segundos hoje. Mas a estratégia vai além da rapidez: o número de paragens (2 vs. 3 stops) e o momento da entrada (undercut vs. overcut) são decisões que emergem dos dados de degradação de pneus.

**Perguntas de análise:**
- *Qual é a evolução histórica do tempo médio de pit stop por construtor?*
- *Qual é a eficácia de undercut vs. overcut com base no desgaste real dos pneus?*
- *Qual o impacto do número de paragens na posição final do piloto?*

### 3.3. O Fator Acaso: Safety Car e Bandeiras Vermelhas

O Safety Car é o grande equalizador. Os dados mostram como uma intervenção do Safety Car altera drasticamente as posições finais do Top 10, comprimindo o pelotão e criando oportunidades para estratégias alternativas.

**Pergunta de análise:** *Qual o impacto estatístico da entrada do Safety Car na alteração das posições finais do Top 10?*

---

## 4. Ato III — A Volta: Onde os Dados Falam Mais Alto

> *"Campeões não se fazem numa volta, mas cada volta define um campeão."*

### 4.1. Consistência vs. Velocidade Máxima

Os dados de tempos por volta (lap times) contam a história de pilotos que mantêm performance consistente ao longo de 50+ voltas vs. pilotos que fazem voltas rápidas isoladas mas perdem tempo em gestão de pneus. A transição de pneus macios para duros é o momento crítico onde a adaptabilidade do piloto se revela.

**Pergunta de análise:** *Como varia a consistência de tempos por volta de um piloto quando este transita de pneus macios para duros?*

### 4.2. Os Setores da Volta

Cada circuito tem zonas de ultrapassagem. Os dados setoriais (S1, S2, S3) permitem identificar onde a ação acontece — e onde os estrategistas devem concentrar recursos.

**Pergunta de análise:** *Em que setor da volta ocorrem mais ultrapassagens em cada circuito?*

### 4.3. Fiabilidade Mecânica

Em condições extremas de temperatura, o risco de falha mecânica aumenta. Os dados de abandono (status) cruzados com condições meteorológicas revelam quais construtores constroem carros fiáveis e quais arriscam demais.

**Pergunta de análise:** *Quais os construtores com maior taxa de abandono por falha mecânica em condições de temperatura elevada?*

---

## 5. Epílogo — O Campeão pelos Números

A narrativa completa-se quando integramos todas as camadas. Um campeão do mundo não é apenas o piloto que cruza a linha primeiro mais vezes — é o que beneficia de:

- Uma consistência ao longo da época (Macro)
- Uma estratégia de corrida otimizada (Meso)
- Uma execução volta a volta consistente (Micro)

Os dados contam a história de sistemas complexos a funcionar em sintonia. Cada tabela, cada métrica, cada visualização é um capítulo dessa história.

---

## 6. Roteiro da Apresentação de Storytelling

| Momento | Duração | Conteúdo | Visualização |
|---|---|---|---|
| Abertura | 2 min | O problema: o que define uma vitória? | Citação/vídeo impactante |
| Ato I | 3 min | Tendências geográficas e classificação de construtores | Mapa de pontos por nacionalidade + evolução de pontos por construtor |
| Ato II | 5 min | Qualificação, pit stops, estratégia, Safety Car | Dashboard de construtores + timeline de corrida |
| Ato III | 3 min | Consistência, setores, fiabilidade | Heatmap de lap times + gráfico de degradação |
| Fecho | 2 min | O campeão pelos números — síntese integrada | Scorecard final do campeão |

---

## 7. Insights-Chave para a Defesa Oral

1. **Correlação não é causalidade** — distinguir os fatores que realmente influenciam a vitória
2. **O contexto importa** — altitude, temperatura, tipo de circuito alteram as conclusões
3. **Evolução temporal** — como as métricas de performance mudaram ao longo das épocas
4. **Trade-offs** — velocidade vs. consistência, risco vs. fiabilidade, undercut vs. overcut
