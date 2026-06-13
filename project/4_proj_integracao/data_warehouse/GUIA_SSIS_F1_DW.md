# Guia de Criação do F1_DW com SSIS

**Mestrado em Ciência de Dados — Business Intelligence**
**Ficha prática: Criação do Data Warehouse F1_DW a partir do F1_DB**

---

## Objetivos

- Compreender o processo de ETL para povoar um Data Warehouse
- Desenvolver uma solução de integração de dados usando SQL Server Integration Services (SSIS)
- Povoar as dimensões e tabelas de factos do F1_DW com base nos dados do F1_DB

## Descrição

Após a análise ao caso de estudo da F1, obteve-se o seguinte modelo dimensional (star schema):

```
                     ┌──────────────────────┐
                     │     Dim_Tempo         │
                     │ Data_SK (PK)          │
                     │ Ano, Trimestre        │
                     │ Mes, Dia, Dia_Semana  │
                     └──────────┬───────────┘
                                │
          ┌─────────────────────┼─────────────────────┐
          │                     │                     │
┌─────────┴───────────┐   ┌────┴───────────┐   ┌─────┴──────────────┐
│   Fact_Performance    │   │  Fact_Volta    │   │   Dim_Composto     │
│ Data_SK (FK)          │   │ Data_SK (FK)   │   │ Composto_SK (PK)   │
│ Piloto_SK (FK)        │   │ Piloto_SK (FK) │   │ Composto            │
│ Circuito_SK (FK)      │   │ Circuito_SK(FK)│   │ Tipo_Piso          │
│ Construtor_SK (FK)    │   │ Construtor_SK  │   └────────────────────┘
│ Pontos_Conquistados   │   │ Composto_SK    │          │
│ Tempo_Total_Pit_Stops │   │ Tempo_Volta_ms │──────────┘
│ Num_Pit_Stops         │   │ Tempo_S1/S2/S3 │
│ Posicoes_Ganhas       │   │ Posicao_na_Volta│
│ Posicao_Partida       │   │ Volta_Sob_SC   │
│ Posicao_Final         │   │ Paragem_Box    │
│ Abandono_Mecanico     │   │ Num_Volta (deg)│
└──┬───────┬───────┬───┘   │ Stint (deg)    │
   │       │       │       └────────────────┘
   │       │       └──────┐
   │       │               │
 ┌─┴───────┴───────────┐ ┌─┴──────────────┐ ┌──────────┴───────────┐
 │     Dim_Piloto        │ │   Dim_Circuito   │ │  Dim_Construtor     │
 │ Piloto_SK (PK)       │ │ Circuito_SK (PK) │ │ Construtor_SK (PK)  │
 │ Nome_Completo        │ │ Nome_Circuito    │ │ Nome                │
 │ Nacionalidade        │ │ Cidade           │ │ Pais                │
 │ Data_Nascimento      │ │ Pais             │ │ Motorizador         │
 │ Equipa (SCD2)        │ │ Continente       │ └─────────────────────┘
 │ Data_Inicio          │ │ Altitude         │
 │ Data_Fim             │ └──────────────────┘
 └──────────────────────┘
```

**Tabela de Factos:**

| Fact Table | Grain | Medidas |
|------------|-------|---------|
| **Fact_Performance** | Uma linha por piloto por corrida | Pontos_Conquistados, Tempo_Total_Pit_Stops, Num_Pit_Stops, Posicoes_Ganhas, Posicao_Partida, Posicao_Final, Abandono_Mecanico |
| **Fact_Volta** | Uma linha por piloto por corrida por volta | Tempo_Volta_ms, Tempo_S1/S2/S3, Posicao_na_Volta, Volta_Sob_SC, Paragem_Box, Stint |

**Dimensões:**

| Dimensão | Tipo | Atributos | SCD |
|----------|------|-----------|-----|
| Dim_Tempo | Role-played | Data_SK, Ano, Trimestre, Mes, Dia, Dia_Semana | Type 0 |
| Dim_Piloto | Conformada | Piloto_SK, Nome_Completo, Nacionalidade, Data_Nascimento, Equipa, Data_Inicio, Data_Fim | Type 2 (Equipa) |
| Dim_Circuito | Conformada | Circuito_SK, Nome_Circuito, Cidade, Pais, Continente, Altitude | Type 1 |
| Dim_Construtor | Conformada | Construtor_SK, Nome, Pais, Motorizador | Type 1 |
| Dim_Composto | Conformada | Composto_SK, Composto (SOFT/MEDIUM/HARD/INTERMEDIATE/WET/Desconhecido), Tipo_Piso | Type 0 |

---

## EXERCÍCIOS PROPOSTOS

## Estrutura base do DATA WAREHOUSE

1. No SQL Server Management Studio estabeleça uma ligação ao servidor de bases de dados, utilizando autenticação Windows (ou SQL Server Authentication).

2. Verifique se a base de dados **F1_DB** já existe no servidor. Esta base de dados contém os dados OLTP de origem (tabelas CSV + JSON) e deve estar populada antes de iniciar o ETL para o F1_DW.

3. Crie a base de dados **F1_DW** executando o script `01_create_dw_database.sql` disponível na pasta `data_warehouse/`:
   - Abra o ficheiro no SSMS
   - Execute o script completo (CREATE DATABASE + CREATE TABLE de todas as dimensões e factos)
   - Verifique se as 7 tabelas foram criadas:
     ```
     Dim_Tempo, Dim_Piloto, Dim_Circuito, Dim_Construtor, Dim_Composto,
     Fact_Performance, Fact_Volta
     ```

4. Execute também o script `02_create_dw_indexes.sql` para criar os índices e chaves estrangeiras necessários.

5. Verifique o diagrama da base de dados **F1_DW** no SSMS (Object Explorer → Databases → F1_DW → Database Diagrams → New Diagram). Adicione as 7 tabelas ao diagrama. Deverá aparecer um diagrama semelhante ao apresentado na página anterior.

---

## ETL — Criação da solução e do projeto de integração

6. Abra o **Microsoft Visual Studio Community** com a carga de trabalho "SQL Server Integration Services" instalada.

7. Na janela principal, clique em **Create a new project**.

8. Na caixa de pesquisa, escreva `integration services` e escolha a opção **Integration Services Project**.

   > **Nota:** O SQL Server Integration Services (SSIS) é uma plataforma para desenvolver projetos de integração e transformação de dados ao nível empresarial. Utilizando esta plataforma vamos preencher com dados a base de dados **F1_DW**.

9. Dê o nome `ProjectSSIS_F1_DW` ao projeto e escolha uma localização adequada (ex: `C:\dev\Projects\f1_dw\project\4_proj_integracao\data_warehouse\`).

10. Antes de implementar qualquer solução, familiarize-se com as secções principais do projeto:
    - **Solution Explorer**: ficheiros do projeto (.dtsx packages, conexões)
    - **SSIS Toolbox**: componentes disponíveis (Data Flow Task, Execute SQL Task, etc.)
    - **Connection Managers**: gestão de ligações às bases de dados
    - **Control Flow**: orquestração das tasks
    - **Data Flow**: transformação e movimento de dados

---

## ETL — Estabelecimento de Ligações

11. O primeiro passo após criar o projeto é definir as conexões às bases de dados. Crie **duas conexões OLE DB**:
    - Ligação à base de dados de origem: **F1_DB**
    - Ligação à base de dados de destino: **F1_DW**

    a. Clique com o botão direito na área **Connection Managers** e escolha **New OLE DB Connection**

    b. Clique em **New**

    c. No **Provider**, escolha **Microsoft OLE DB Driver for SQL Server**

    d. Estabeleça a ligação ao servidor, escolhendo a base de dados **F1_DB**:

    ```
    Server: (local) ou NOME_DO_SERVIDOR
    Authentication: Windows Authentication (ou SQL Server Authentication)
    Database: F1_DB
    ```

    e. Clique em **OK**

    f. Repita os passos a) a e) para criar uma segunda ligação, desta vez selecionando a base de dados **F1_DW**

12. Após a criação das duas conexões, faça **OK** para voltar à janela principal. Deverá ver ambas as conexões listadas na área Connection Managers:
    - `(local).F1_DB` (ou nome que escolheu)
    - `(local).F1_DW`

    > **Nota:** Pode renomear as conexões para `F1_DB` e `F1_DW` clicando com o botão direito → Rename.

---

## ETL — Tabelas de Dimensão

13. Para exportar dados da base de dados **F1_DB** para o Data Warehouse **F1_DW** (preencher de forma automática as dimensões e tabelas de factos: tempo, piloto, circuito, construtor, composto, fact_performance e fact_volta), irá precisar de adicionar ao seu projeto componentes do tipo **Data Flow Task** (um por cada tabela destino).

    Na **SSIS Toolbox**, clique e arraste o componente **Data Flow Task** 7 vezes para a área do **Control Flow**. Renomeie-os como:

    ```
    DFT Dim_Tempo
    DFT Dim_Composto
    DFT Dim_Circuito
    DFT Dim_Construtor
    DFT Dim_Piloto
    DFT Fact_Performance
    DFT Fact_Volta
    ```

14. Ligue os componentes entre si (clicar na seta verde e arrastar para cima do próximo componente). As tabelas de factos têm de ser sempre as últimas (dependem das dimensões). A ordem de execução será:

    ```
    Dim_Tempo → Dim_Composto → Dim_Circuito → Dim_Construtor → Dim_Piloto → Fact_Performance → Fact_Volta
    ```

15. Vamos agora configurar cada um dos componentes anteriores. De seguida é apresentada a estrutura final de cada **Data Flow Task**:

    a. **DFT Dim_Tempo:**

    ```
    [OLE DB Source (F1_DB)] → [OLE DB Destination (F1_DW.dbo.Dim_Tempo)]
    ```

    b. **DFT Dim_Composto:**

    ```
    [OLE DB Source (F1_DB, query composta)] → [OLE DB Destination (F1_DW.dbo.Dim_Composto)]
    ```

    c. **DFT Dim_Circuito:**

    ```
    [OLE DB Source (F1_DB)] → [Derived Column (Continente, Altitude)] → [OLE DB Destination (F1_DW.dbo.Dim_Circuito)]
    ```

    d. **DFT Dim_Construtor:**

    ```
    [OLE DB Source (F1_DB)] → [Derived Column (Motorizador)] → [OLE DB Destination (F1_DW.dbo.Dim_Construtor)]
    ```

    e. **DFT Dim_Piloto (SCD Type 2):**

    ```
    [OLE DB Source (F1_DB, timeline query)] → [Derived Column (Nome_Completo)]
    → [Lookup (verificar existente em Dim_Piloto)]
    → [Conditional Split (novo vs existente)]
    → [OLE DB Destination] + [OLE DB Command (UPDATE Data_Fim do anterior)]
    ```

    f. **DFT Fact_Performance:**

    ```
    [OLE DB Source (F1_DB, results + pit_stops agg)] → [Lookup x4 (Data_SK, Piloto_SK, Circuito_SK, Construtor_SK)]
    → [Derived Column (Posicoes_Ganhas, Abandono_Mecanico)]
    → [OLE DB Destination (F1_DW.dbo.Fact_Performance)]
    ```

    g. **DFT Fact_Volta:**

    ```
    [OLE DB Source (F1_DB, lap_times + safety + pits)] → [Lookup x5 (Data_SK, Piloto_SK, Circuito_SK, Construtor_SK, Composto_SK)]
    → [OLE DB Destination (F1_DW.dbo.Fact_Volta)]
    ```

---

16. **Configure o Data Flow Dim_Tempo:**

    a. Faça duplo clique em **DFT Dim_Tempo**

    b. Arraste um componente **OLE DB Source** para a área do Data Flow

    c. Faça duplo clique no componente e escolha:
       - **Connection Manager:** F1_DB
       - **Data access mode:** SQL command
       - **SQL command text:**

       ```sql
       SELECT DISTINCT
           CAST(CONVERT(VARCHAR(8), r.date, 112) AS INT) AS Data_SK,
           YEAR(r.date) AS Ano,
           DATEPART(QUARTER, r.date) AS Trimestre,
           MONTH(r.date) AS Mes,
           DAY(r.date) AS Dia,
           DATEPART(WEEKDAY, r.date) AS Dia_Semana
       FROM F1_DB.dbo.races r
       ```

    d. Clique em **Preview** para verificar os dados

    e. Arraste um componente **OLE DB Destination** para a área do Data Flow

    f. Ligue a seta verde do OLE DB Source ao OLE DB Destination

    g. Faça duplo clique no OLE DB Destination:
       - **Connection Manager:** F1_DW
       - **Table or view:** [dbo].[Dim_Tempo]
       - No separador **Mappings**, verifique se todas as colunas estão mapeadas corretamente

    h. Volte ao separador **Control Flow**

    i. Selecione o componente **DFT Dim_Tempo**, clique com o botão direito e escolha **Execute Task**

    j. Após execução bem-sucedida (checkmark verde), volte ao SSMS e verifique:
       ```sql
       SELECT COUNT(*) AS registos FROM F1_DW.dbo.Dim_Tempo;
       ```
       Deverá obter cerca de 1171 registos (corridas entre 1950 e 2026).

    k. Volte ao Visual Studio e faça **Stop** da execução.

---

17. **Configure o Data Flow Dim_Composto:**

    > **Nota:** A dimensão Composto é uma dimensão estática com 6 registos pré-definidos.

    a. Faça duplo clique em **DFT Dim_Composto**

    b. Arraste um componente **OLE DB Source** para a área do Data Flow

    c. Configure com **SQL command:**

    ```sql
    SELECT 1 AS Composto_SK, 'Desconhecido' AS Composto, 'Desconhecido' AS Tipo_Piso
    UNION ALL
    SELECT 2, 'SOFT', 'Seco'
    UNION ALL
    SELECT 3, 'MEDIUM', 'Seco'
    UNION ALL
    SELECT 4, 'HARD', 'Seco'
    UNION ALL
    SELECT 5, 'INTERMEDIATE', 'Chuva'
    UNION ALL
    SELECT 6, 'WET', 'Chuva'
    ```

    d. Adicione um **OLE DB Destination** e ligue ao F1_DW.dbo.Dim_Composto

    e. Execute a task e verifique no SSMS:
       ```sql
       SELECT * FROM F1_DW.dbo.Dim_Composto;
       ```

---

18. **Configure o Data Flow Dim_Circuito:**

    a. Faça duplo clique em **DFT Dim_Circuito**

    b. Arraste um **OLE DB Source** e configure com F1_DB e SQL command:

    ```sql
    SELECT
        circuitId AS Circuito_SK,
        name AS Nome_Circuito,
        location AS Cidade,
        CASE country
            WHEN 'USA' THEN 'United States'
            ELSE country
        END AS Pais,
        alt AS Altitude
    FROM F1_DB.dbo.circuits
    ```

    c. Arraste um componente **Derived Column** para o Data Flow

    d. Ligue o OLE DB Source ao Derived Column

    e. Faça duplo clique no Derived Column e crie duas novas colunas:
       - **Coluna:** `Continente` | **Expression:**
         ```
         (Pais == "Portugal" || Pais == "Spain" || Pais == "Italy" || Pais == "France" || Pais == "Germany" || Pais == "UK" || Pais == "United Kingdom" || Pais == "Belgium" || Pais == "Netherlands" || Pais == "Monaco" || Pais == "Hungary" || Pais == "Austria" || Pais == "Russia" || Pais == "Finland" || Pais == "Sweden" || Pais == "Switzerland" || Pais == "Turkey" || Pais == "Azerbaijan") ? "Europa" :
         (Pais == "Brazil" || Pais == "Argentina" || Pais == "Mexico" || Pais == "United States" || Pais == "Canada") ? "America" :
         (Pais == "Bahrain" || Pais == "UAE" || Pais == "Abu Dhabi" || Pais == "China" || Pais == "Japan" || Pais == "South Korea" || Pais == "Malaysia" || Pais == "Singapore" || Pais == "India" || Pais == "Qatar" || Pais == "Saudi Arabia") ? "Asia" :
         (Pais == "Australia" || Pais == "New Zealand") ? "Oceania" :
         (Pais == "South Africa" || Pais == "Morocco") ? "Africa" :
         "Desconhecido"
         ```
       - **Coluna:** `Altitude` | **Expression:**
         ```
         ISNULL(Altitude) ? -1 : Altitude
         ```

    f. Arraste um **OLE DB Destination** (F1_DW.dbo.Dim_Circuito), ligue o Derived Column, e verifique os mappings

    g. Execute a task e verifique no SSMS:
       ```sql
       SELECT COUNT(*) FROM F1_DW.dbo.Dim_Circuito;  -- 78 registos
       ```

---

19. **Configure o Data Flow Dim_Construtor:**

    a. Faça duplo clique em **DFT Dim_Construtor**

    b. Arraste um **OLE DB Source** (F1_DB) com SQL command:

    ```sql
    SELECT
        constructorId AS Construtor_SK,
        name AS Nome,
        nationality AS Pais
    FROM F1_DB.dbo.constructors
    ```

    c. Adicione um **Derived Column** com a coluna:
       - **Coluna:** `Motorizador` | **Expression:**
         ```
         (Nome == "McLaren" || Nome == "McLaren Honda" || Nome == "Visa Cash App RB" || Nome == "RB F1 Team" || Nome == "Williams" || Nome == "Racing Bulls" || Nome == "Mercedes" || Nome == "Brawn GP" || Nome == "Force India" || Nome == "Racing Point" || Nome == "Aston Martin" || Nome == "Lotus F1" || Nome == "Manor" || Nome == "Virgin" || Nome == "Marussia") ? "Mercedes" :
         (Nome == "Red Bull" || Nome == "AlphaTauri" || Nome == "Toro Rosso" || Nome == "RB") ? "Honda RBPT" :
         (Nome == "Ferrari" || Nome == "Alfa Romeo" || Nome == "Sauber" || Nome == "Kick Sauber" || Nome == "Haas") ? "Ferrari" :
         (Nome == "Alpine" || Nome == "Renault" || Nome == "Lotus" || Nome == "Benetton" || Nome == "Prost" || Nome == "Toleman" || Nome == "Equipe Ligier" || Nome == "Matra" || Nome == "Gordini" || Nome == "Bugatti" || Nome == "Talbot-Lago") ? "Renault" :
         "Outro"
         ```

    d. Ligue o Source → Derived Column → OLE DB Destination (F1_DW.dbo.Dim_Construtor)

    e. Execute a task e verifique no SSMS

---

20. **Configure o Data Flow Dim_Piloto (SCD Type 2):**

    > **Nota importante:** Esta é a dimensão mais complexa, pois implementa **Slowly Changing Dimension Type 2** no atributo Equipa. Como o VS2022 já não inclui o SCD Wizard, vamos implementar manualmente.

    a. Faça duplo clique em **DFT Dim_Piloto**

    b. Arraste um **OLE DB Source** (F1_DB) com SQL command. Esta query constrói a timeline de equipas por piloto, detetando mudanças de equipa ao longo do tempo:

    ```sql
    WITH driver_team_changes AS (
        SELECT
            r.driverId,
            d.forename,
            d.surname,
            d.nationality,
            d.dob,
            c.name AS equipa,
            rc.date AS race_date,
            LAG(c.name) OVER (PARTITION BY r.driverId ORDER BY rc.date) AS prev_equipa
        FROM F1_DB.dbo.results r
        JOIN F1_DB.dbo.races rc ON r.raceId = rc.raceId
        JOIN F1_DB.dbo.drivers d ON r.driverId = d.driverId
        JOIN F1_DB.dbo.constructors c ON r.constructorId = c.constructorId
    ),
    team_groups AS (
        SELECT *,
            SUM(CASE WHEN equipa != prev_equipa OR prev_equipa IS NULL
                THEN 1 ELSE 0 END)
                OVER (PARTITION BY driverId ORDER BY race_date) AS grp
        FROM driver_team_changes
    )
    SELECT
        driverId,
        forename,
        surname,
        nationality,
        dob,
        equipa,
        MIN(race_date) AS Data_Inicio,
        CASE
            WHEN MAX(race_date) < (SELECT MAX(date) FROM F1_DB.dbo.races)
            THEN DATEADD(DAY, 1, MAX(race_date))
            ELSE NULL
        END AS Data_Fim
    FROM team_groups
    GROUP BY driverId, forename, surname, nationality, dob, equipa, grp
    ORDER BY driverId, Data_Inicio
    ```

    c. Adicione um **Derived Column** para concatenar o nome:
       - **Coluna:** `Nome_Completo` | **Expression:**
         ```
         forename + " " + surname
         ```

    d. Adicione um **Lookup** para verificar se o registo já existe no destino:
       - **Connection:** F1_DW
       - **Use results of a SQL query:**
         ```sql
         SELECT Nome_Completo, Data_Inicio FROM F1_DW.dbo.Dim_Piloto
         ```
       - No separador **Columns**, mapeie:
         - `Nome_Completo` (source) → `Nome_Completo` (lookup)
         - `Data_Inicio` (source) → `Data_Inicio` (lookup)
       - No separador **General**, em **Specify how to handle rows with no matching entries**, escolha **Redirect rows to no match output**

    e. Adicione um **Conditional Split** para separar:
       - **Caminho 1 (novo piloto):** `LookupOutput == "NoMatch"`
       - **Caminho 2 (já existe):** `LookupOutput == "Match"` (ignorar)

    f. Ligue o Conditional Split (caminho dos novos) a um **OLE DB Destination** (F1_DW.dbo.Dim_Piloto)

    g. Execute a task

    h. No SSMS, verifique se os dados foram carregados:
       ```sql
       SELECT TOP 10 * FROM F1_DW.dbo.Dim_Piloto;
       SELECT COUNT(*) FROM F1_DW.dbo.Dim_Piloto;
       ```
       Deverá obter mais registos do que o total de pilotos (865+), pois cada mudança de equipa gera um novo registo.

---

## ETL — Tabelas de Factos

21. **Configure o Data Flow Fact_Performance:**

    a. Faça duplo clique em **DFT Fact_Performance**

    b. Arraste um **OLE DB Source** (F1_DB) com SQL command. Esta query junta dados de resultados, corridas, status e pit stops:

    ```sql
    SELECT
        r.resultId,
        r.raceId,
        r.driverId,
        r.constructorId,
        rc.date,
        rc.circuitId,
        r.points,
        r.grid,
        r.position,
        s.status,
        COALESCE(ps.total_duration, 0) AS total_pit_duration,
        COALESCE(ps.stop_count, 0) AS num_pit_stops
    FROM F1_DB.dbo.results r
    JOIN F1_DB.dbo.races rc ON r.raceId = rc.raceId
    JOIN F1_DB.dbo.status s ON r.statusId = s.statusId
    OUTER APPLY (
        SELECT
            SUM(ps.duration) AS total_duration,
            COUNT(DISTINCT ps.stop) AS stop_count
        FROM F1_DB.dbo.pit_stops ps
        WHERE ps.raceId = r.raceId AND ps.driverId = r.driverId
    ) ps
    ```

    c. Adicione 4 componentes **Lookup** (ou um Lookup com várias tabelas) para obter as surrogate keys:

    **Lookup 1 — Data_SK:**
    - Connection: F1_DW
    - SQL: `SELECT Data_SK, Ano, Mes, Dia FROM F1_DW.dbo.Dim_Tempo`
    - Mapear: `date` → `Data_SK` (através de `Ano + Mes + Dia` ou usar função)
    - **Alternativa mais simples** — usar Direct Lookup com a expressão:
      ```
      (YEAR(date) * 10000 + MONTH(date) * 100 + DAY(date))
      ```
      No entanto, o Lookup exige correspondência exata. Use a seguinte query:
      ```sql
      SELECT Data_SK, Ano, Mes, Dia FROM F1_DW.dbo.Dim_Tempo
      ```

    **Lookup 2 — Piloto_SK:**
    - Connection: F1_DW
    - SQL: `SELECT Piloto_SK, Nome_Completo, Data_Inicio, Data_Fim FROM F1_DW.dbo.Dim_Piloto`
    - Mapeamento necessário: `driverId` → `Nome_Completo` (via JOIN ao F1_DB.dbo.drivers na origem, ou usar 2º Lookup)
    - **Solução:** incluir `forename + surname` na query de origem e mapear para `Nome_Completo` com filtro de data:

    **Simplificação:** Para evitar Lookups complexos com SCD2, altere a query de origem para:

    ```sql
    SELECT
        r.resultId, r.raceId, r.driverId, r.constructorId,
        rc.date, rc.circuitId, r.points, r.grid, r.position,
        s.status,
        CONCAT(d.forename, ' ', d.surname) AS Nome_Completo,
        COALESCE(ps.total_duration, 0) AS total_pit_duration,
        COALESCE(ps.stop_count, 0) AS num_pit_stops
    FROM F1_DB.dbo.results r
    JOIN F1_DB.dbo.races rc ON r.raceId = rc.raceId
    JOIN F1_DB.dbo.drivers d ON r.driverId = d.driverId
    JOIN F1_DB.dbo.status s ON r.statusId = s.statusId
    OUTER APPLY (... ) ps
    ```

    E faça um único **Lookup** com 3 joins virtuais na query:

    ```sql
    SELECT
        dt.Data_SK,
        dp.Piloto_SK,
        dc.Circuito_SK,
        dco.Construtor_SK
    FROM F1_DW.dbo.Dim_Tempo dt
    CROSS JOIN F1_DW.dbo.Dim_Piloto dp -- não, isto não funciona
    ```

    **Abordagem final recomendada:** Use 3 Lookups separados:

    | Lookup | Tabela de lookup | Coluna origem → destino |
    |--------|-----------------|------------------------|
    | Lookup Data | `SELECT Data_SK, Ano, Mes, Dia FROM Dim_Tempo` | Criar Ano/Mes/Dia na origem com Derived Column |
    | Lookup Piloto | `SELECT Piloto_SK, Nome_Completo FROM Dim_Piloto WHERE Data_Fim IS NULL` | `Nome_Completo` → `Nome_Completo` (apenas versão atual) |
    | Lookup Circuito | `SELECT Circuito_SK, Nome_Circuito FROM Dim_Circuito` | Incluir `Circuito_SK` diretamente na origem |
    | Lookup Construtor | `SELECT Construtor_SK, Nome FROM Dim_Construtor` | Incluir `Construtor_SK` diretamente na origem |

    d. Para simplificar, altere novamente a query de origem para incluir os SKs diretamente:

    ```sql
    SELECT
        r.resultId,
        rc.date,
        CONCAT(d.forename, ' ', d.surname) AS Nome_Completo,
        rc.circuitId,    -- será usado como Circuito_SK (coincide)
        r.constructorId, -- será usado como Construtor_SK (coincide)
        r.points AS Pontos_Conquistados,
        r.grid AS Posicao_Partida,
        r.position AS Posicao_Final,
        s.status,
        COALESCE(ps.total_duration, 0) AS Tempo_Total_Pit_Stops,
        COALESCE(ps.stop_count, 0) AS Num_Pit_Stops
    FROM F1_DB.dbo.results r ... (resto igual)
    ```

    e. Adicione **Derived Column** para as medidas calculadas:
       - `Data_SK`: `(YEAR(date) * 10000) + (MONTH(date) * 100) + DAY(date)` (tipo: `DT_I4`)
       - `Posicoes_Ganhas`: `Posicao_Partida - Posicao_Final` (tipo: `DT_I4`)
         - Se `Posicao_Final IS NULL`, usar 0
       - `Abandono_Mecanico`: flag baseada no campo `status`
         ```
         (FINDSTRING(status, "Engine", 1) > 0 || FINDSTRING(status, "Gearbox", 1) > 0 || FINDSTRING(status, "Transmission", 1) > 0 || FINDSTRING(status, "Hydraulics", 1) > 0 || FINDSTRING(status, "Suspension", 1) > 0 || FINDSTRING(status, "Brakes", 1) > 0 || FINDSTRING(status, "Electrical", 1) > 0 || FINDSTRING(status, "Clutch", 1) > 0 || FINDSTRING(status, "Fuel", 1) > 0 || FINDSTRING(status, "Overheating", 1) > 0) ? 1 : 0
         ```

    f. Adicione um **OLE DB Destination** (F1_DW.dbo.Fact_Performance) e mapeie todas as colunas

    g. Execute a task e verifique no SSMS:
       ```sql
       SELECT COUNT(*) FROM F1_DW.dbo.Fact_Performance;  -- ~27.370 registos
       ```

---

22. **Configure o Data Flow Fact_Volta:**

    a. Faça duplo clique em **DFT Fact_Volta**

    b. Arraste um **OLE DB Source** (F1_DB) com SQL command. Esta query junta lap_times, races, drivers, com dados opcionais de safety car e pit stops:

    ```sql
    SELECT
        lt.raceId, lt.driverId, lt.lap, lt.milliseconds, lt.position AS pos_lap,
        rc.date, rc.circuitId, rc.name AS gp_name, rc.year,
        CONCAT(d.forename, ' ', d.surname) AS Nome_Completo,
        dl.stint, dl.s1, dl.s2, dl.s3, dl.compound,
        CASE WHEN sc.Race IS NOT NULL THEN 1 ELSE 0 END AS Volta_Sob_SC,
        CASE WHEN ps.lap IS NOT NULL THEN 1 ELSE 0 END AS Paragem_Box
    FROM F1_DB.dbo.lap_times lt
    JOIN F1_DB.dbo.races rc ON lt.raceId = rc.raceId
    JOIN F1_DB.dbo.drivers d ON lt.driverId = d.driverId
    LEFT JOIN F1_DB.dbo.driver_laptimes dl
        ON dl.driver_code = d.code
        AND dl.lap = lt.lap
        AND dl.session_id IN (
            SELECT session_id FROM F1_DB.dbo.sessions
            WHERE sessao = 'Race' AND ano = rc.year AND gp = rc.name
        )
    LEFT JOIN F1_DB.dbo.safety_cars sc
        ON rc.name = sc.Race AND lt.lap BETWEEN sc.Deployed AND ISNULL(sc.Retreated, 999)
    LEFT JOIN F1_DB.dbo.pit_stops ps
        ON lt.raceId = ps.raceId AND lt.driverId = ps.driverId AND lt.lap = ps.lap
    ```

    > **Nota:** Esta query pode demorar a executar devido ao volume de dados (~873K linhas). Considere testar com um subconjunto (ex: `WHERE rc.year >= 2024`) durante o desenvolvimento.

    c. Adicione **Derived Column** para as SKs:
       - `Data_SK`: `(YEAR(date) * 10000) + (MONTH(date) * 100) + DAY(date)` (`DT_I4`)
       - `Tempo_Volta_ms`: usar `milliseconds` diretamente (`DT_I4`)

    d. Adicione **Lookups** para:
       - **Lookup Piloto:** `SELECT Piloto_SK, Nome_Completo FROM F1_DW.dbo.Dim_Piloto WHERE Data_Fim IS NULL`
       - **Lookup Circuito:** mapear `circuitId` → `Circuito_SK` (coincidem)
       - **Lookup Construtor:** incluir na query de origem via JOIN a `results` (adicionar `r.constructorId` na query)
       - **Lookup Composto:** mapear `compound` → `Composto_SK`
         ```sql
         SELECT Composto_SK, Composto FROM F1_DW.dbo.Dim_Composto
         ```

    e. Adicione um **OLE DB Destination** (F1_DW.dbo.Fact_Volta)

    f. Execute a task. Como são muitos registos, a execução pode demorar alguns minutos.

    g. Verifique no SSMS:
       ```sql
       SELECT COUNT(*) FROM F1_DW.dbo.Fact_Volta;  -- ~873.000 registos (1996-2026)
       SELECT TOP 10 * FROM F1_DW.dbo.Fact_Volta;
       ```

---

## Execução Completa e Verificação

23. No separador **Control Flow**, clique em **Start** (triângulo verde) para executar todo o fluxo de dados.

24. O processo terminará quando todas as tasks tiverem um visto verde:

    ```
    ✔ DFT Dim_Tempo
    ✔ DFT Dim_Composto
    ✔ DFT Dim_Circuito
    ✔ DFT Dim_Construtor
    ✔ DFT Dim_Piloto
    ✔ DFT Fact_Performance
    ✔ DFT Fact_Volta
    ```

25. Faça **Stop** da execução.

26. No **SQL Server Management Studio**, execute as seguintes consultas de verificação:

    ```sql
    -- Total de registos por tabela
    SELECT 'Dim_Tempo' AS tabela, COUNT(*) AS registos FROM F1_DW.dbo.Dim_Tempo
    UNION ALL
    SELECT 'Dim_Composto', COUNT(*) FROM F1_DW.dbo.Dim_Composto
    UNION ALL
    SELECT 'Dim_Circuito', COUNT(*) FROM F1_DW.dbo.Dim_Circuito
    UNION ALL
    SELECT 'Dim_Construtor', COUNT(*) FROM F1_DW.dbo.Dim_Construtor
    UNION ALL
    SELECT 'Dim_Piloto', COUNT(*) FROM F1_DW.dbo.Dim_Piloto
    UNION ALL
    SELECT 'Fact_Performance', COUNT(*) FROM F1_DW.dbo.Fact_Performance
    UNION ALL
    SELECT 'Fact_Volta', COUNT(*) FROM F1_DW.dbo.Fact_Volta
    ORDER BY tabela;
    ```

    Resultados esperados:

    | Tabela | Registos (aprox.) |
    |--------|------------------|
    | Dim_Tempo | 1.171 |
    | Dim_Composto | 6 |
    | Dim_Circuito | 78 |
    | Dim_Construtor | 214 |
    | Dim_Piloto | 900+ (com SCD2) |
    | Fact_Performance | 27.370 |
    | Fact_Volta | 873.000 |

27. **Consultas de análise de exemplo:**

    ```sql
    -- Pontos por construtor (últimos 20 anos)
    SELECT
        dc.Nome AS Construtor,
        dt.Ano,
        SUM(fp.Pontos_Conquistados) AS Total_Pontos
    FROM F1_DW.dbo.Fact_Performance fp
    JOIN F1_DW.dbo.Dim_Tempo dt ON fp.Data_SK = dt.Data_SK
    JOIN F1_DW.dbo.Dim_Construtor dc ON fp.Construtor_SK = dc.Construtor_SK
    WHERE dt.Ano >= 2006
    GROUP BY dc.Nome, dt.Ano
    ORDER BY dt.Ano DESC, Total_Pontos DESC;

    -- Média de tempo de volta por piloto e circuito (2024)
    SELECT
        dp.Nome_Completo AS Piloto,
        dc.Nome_Circuito,
        AVG(fv.Tempo_Volta_ms) / 1000.0 AS Tempo_Medio_Seg
    FROM F1_DW.dbo.Fact_Volta fv
    JOIN F1_DW.dbo.Dim_Tempo dt ON fv.Data_SK = dt.Data_SK
    JOIN F1_DW.dbo.Dim_Piloto dp ON fv.Piloto_SK = dp.Piloto_SK
    JOIN F1_DW.dbo.Dim_Circuito dc ON fv.Circuito_SK = dc.Circuito_SK
    WHERE dt.Ano = 2024
    GROUP BY dp.Nome_Completo, dc.Nome_Circuito
    ORDER BY Piloto, dc.Nome_Circuito;
    ```

---

## Conclusão

O Data Warehouse **F1_DW** está agora concluído em termos de estrutura e dados.

Foram carregados dados históricos desde 1950 até 2026, permitindo análises multidimensionais sobre desempenho de pilotos, construtores, circuitos, e voltas, com suporte para:

- SCD Type 2 na dimensão Piloto (histórico de equipas)
- Dimensão Tempo com hierarquia Ano → Trimestre → Mes → Dia
- Modelo de constelação de factos (Fact_Performance + Fact_Volta) com dimensões conformadas
- Indicadores de negócio como abandono mecânico, posições ganhas, voltas sob safety car
