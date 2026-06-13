# Descrição do Projeto — Business Intelligence na Formula 1

## 1. Objetivos do Projeto

Desenvolvimento de uma solução completa de Business Intelligence (BI) focada no domínio da **Formula 1**, cobrindo desde a extração de dados operacionais até à visualização analítica e storytelling. O sistema visa consolidar dados históricos de corridas, pilotos, construtores e circuitos para responder a questões estratégicas e de performance sobre o desporto.

**Objetivos específicos:**
- Construir um **Data Warehouse** dimensional (star schema) a partir de fontes OLTP históricas
- Implementar **pipelines ETL** para extração, transformação e carga dos dados
- Desenvolver **dashboards analíticos** no Power BI para apoio à decisão
- Produzir uma **narrativa de dados (storytelling)** sobre "A Anatomia de uma Vitória"

## 2. Promotores e Stakeholders

| Papel | Entidade |
|---|---|
| **Promotor Académico** | Unidade Curricular de Business Intelligence, Mestrado em Ciência de Dados |
| **Sponsor do Projeto** | Direção de Desporto Motorizado da FIA / equipas de F1 (stakeholder simulado) |
| **Diretor Técnico** | Foco em fiabilidade e performance mecânica |
| **Estrategista de Corrida Chefe** | Foco em estratégias de paragens e degradação de pneus |
| **Analista de Dados Sénior** | Foco em métricas de consistência e ultrapassagens |
| **Utilizadores-alvo** | Estrategistas de corrida, analistas de performance de equipas, jornalistas especializados e comentadores técnicos |

## 3. Requisitos

### 3.1. Requisitos Académicos
- Grupo com máximo de **3 estudantes**
- Submissão da proposta via Moodle até **15 de maio**
- Entregáveis: relatório PDF (template IEEE opcional), apresentação PowerPoint, ficheiros fonte e código
- Defesa oral com presença obrigatória de todos os membros

### 3.2. Requisitos de Negócio
- Comparação direta de performance entre equipas
- Previsão de degradação de pneus por circuito
- Avaliação de custo-benefício dos investimentos técnicos

### 3.3. Requisitos Técnicos
- **Fontes de Dados:** Ergast API / datasets históricos de F1 (CSV), telemetria (JSON), dados meteorológicos e financeiros
- **ETL:** Python (pandas) + SQL Server Integration Services (SSIS)
- **Armazenamento:** SQL Server / PostgreSQL
- **Visualização:** Power BI
- **Modelo Dimensional:** Constelação de factos com `Fact_Performance` (grão piloto×corrida) e `Fact_Volta` (grão piloto×corrida×volta); dimensões `Dim_Tempo`, `Dim_Piloto`, `Dim_Circuito`, `Dim_Construtor`, `Dim_Composto`
- **Medidas:** `Fact_Performance` — Pontos, Tempo Total Pit Stops, Posições Ganhas, Abandono Mecânico; `Fact_Volta` — Tempo Volta, Tempos Setor S1/S2/S3, Posição na Volta, Volta Sob SC, Paragem Box
- **Refrescamento:** Incremental, agendado nas 24h após cada Grande Prémio

### 3.4. Requisitos de Qualidade
- Validação de integridade referencial entre factos e dimensões
- Monitorização de duplicados nas tabelas de dimensões
- Registo de métricas de qualidade (linhas carregadas, rejeitadas)

## 4. Questões a Responder (10 questões de análise)

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

## 5. Entrevistas Diligenciadas e User Stories

### 5.1. Entrevista com o Diretor Técnico
**Foco:** Fiabilidade e performance mecânica

> **User Story 1:** Como **Diretor Técnico**, quero comparar o tempo de pit stop da minha equipa com os concorrentes diretos para identificar janelas de otimização mecânica.

> **User Story 2:** Como **Diretor Técnico**, quero analisar a taxa de abandono por falha mecânica em condições de temperatura elevada para avaliar a robustez do motor e dos sistemas do carro.

### 5.2. Entrevista com o Estrategista de Corrida Chefe
**Foco:** Estratégias de paragens e degradação de pneus

> **User Story 3:** Como **Estrategista de Corrida**, quero simular o impacto de janelas de paragem com base no histórico de degradação de pneu por circuito para mitigar o risco de perda de posição em pista.

> **User Story 4:** Como **Estrategista de Corrida**, quero comparar a eficácia de estratégias de *undercut* vs. *overcut* em cada circuito para maximizar o ganho de posições nas paragens.

> **User Story 5:** Como **Estrategista de Corrida**, quero avaliar o impacto do número de paragens (2 vs. 3 stops) na posição final do piloto para definir a estratégia ótima para cada corrida.

### 5.3. Entrevista com o Analista de Dados Sénior
**Foco:** Métricas de consistência e ultrapassagens

> **User Story 6:** Como **Analista de Dados Sénior**, quero analisar a consistência de tempos por volta de um piloto quando transita de pneus macios para duros para avaliar a adaptabilidade e gestão de pneus.

> **User Story 7:** Como **Analista de Dados Sénior**, quero identificar os pilotos com maior ganho líquido de posições na primeira volta a partir de posições intermédias da grelha (P10-P15) para detetar talentos em pilotos de equipas de meio do pelotão.

> **User Story 8:** Como **Analista de Dados Sénior**, quero correlacionar a posição de pole position com a vitória final segmentado por altitude do circuito para entender a vantagem competitiva da qualificação em diferentes tipos de circuito.

### 5.4. Entrevista com Jornalista Especializado / Comentador Técnico
**Foco:** Narrativa de dados e contexto histórico

> **User Story 9:** Como **Jornalista Especializado**, quero visualizar a distribuição geográfica dos pontos conquistados por nacionalidade de pilotos nos últimos 20 anos para identificar tendências e hegemonias regionais no desporto.

> **User Story 10:** Como **Comentador Técnico**, quero analisar o impacto da entrada do Safety Car na alteração das posições finais do Top 10 para explicar ao público reviravoltas inesperadas nos resultados das corridas.

> **User Story 11:** Como **Comentador Técnico**, quero identificar o setor da volta (S1, S2 ou S3) com mais ultrapassagens em cada circuito para enriquecer a narração em tempo real durante as transmissões.
