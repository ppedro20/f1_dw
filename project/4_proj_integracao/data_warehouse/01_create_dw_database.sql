-- ============================================================
-- F1_DW - Base de Dados OLAP (Data Warehouse)
-- ============================================================
-- Modelo dimensional em estrela com duas tabelas de factos
-- (Fact_Performance, Fact_Volta) e cinco dimensoes
-- (Dim_Tempo, Dim_Piloto, Dim_Circuito, Dim_Construtor, Dim_Composto)
-- ============================================================

USE master;
GO

-- Drop se existir (para permitir re-execucao limpa)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'F1_DW')
BEGIN
    ALTER DATABASE F1_DW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE F1_DW;
END
GO

CREATE DATABASE F1_DW;
GO

USE F1_DW;
GO

PRINT 'Base de dados F1_DW criada com sucesso.';
GO

-- ============================================================
-- DIMENSOES
-- ============================================================

-- ----------------------------------------------------------
-- Dim_Tempo (SCD Type 0)
-- Granularidade: dia (apenas dias com corridas)
-- Hierarquia: Ano > Trimestre > Mes > Dia
-- ----------------------------------------------------------
CREATE TABLE Dim_Tempo (
    Data_SK        INT         NOT NULL PRIMARY KEY,   -- YYYYMMDD
    Ano            INT         NOT NULL,
    Trimestre      INT         NOT NULL,                -- 1 a 4
    Mes            INT         NOT NULL,                -- 1 a 12
    Dia            INT         NOT NULL,                -- 1 a 31
    Dia_Semana     INT         NOT NULL                 -- 1=domingo, 2=segunda, ...
);
GO

-- ----------------------------------------------------------
-- Dim_Piloto (SCD Type 2 sobre Equipa)
-- Um novo registo e criado sempre que o piloto muda de equipa.
-- Data_Inicio/Data_Fim definem a janela temporal de validade.
-- ----------------------------------------------------------
CREATE TABLE Dim_Piloto (
    Piloto_SK       INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nome_Completo   VARCHAR(101)      NOT NULL,
    Nacionalidade   VARCHAR(50)       NULL,
    Data_Nascimento DATE              NULL,
    Equipa          VARCHAR(100)      NOT NULL,
    Data_Inicio     DATE              NOT NULL,
    Data_Fim        DATE              NULL              -- NULL = registo atual
);
GO

-- ----------------------------------------------------------
-- Dim_Circuito (SCD Type 1)
-- Hierarquia: Continente > Pais > Cidade > Circuito
-- ----------------------------------------------------------
CREATE TABLE Dim_Circuito (
    Circuito_SK    INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nome_Circuito  VARCHAR(100)      NOT NULL,
    Cidade         VARCHAR(100)      NULL,
    Pais           VARCHAR(50)       NULL,
    Continente     VARCHAR(50)       NULL,
    Altitude       INT               NULL               -- -1 = desconhecido
);
GO

-- ----------------------------------------------------------
-- Dim_Construtor (SCD Type 1)
-- ----------------------------------------------------------
CREATE TABLE Dim_Construtor (
    Construtor_SK INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    Nome          VARCHAR(100)      NOT NULL,
    Pais          VARCHAR(50)       NULL,
    Motorizador   VARCHAR(50)       NULL
);
GO

-- ----------------------------------------------------------
-- Dim_Composto (SCD Type 0 - tabela estatica)
-- Registos pre-definidos:
--   1 = Desconhecido, 2 = SOFT, 3 = MEDIUM, 4 = HARD,
--   5 = INTERMEDIATE, 6 = WET
-- ----------------------------------------------------------
CREATE TABLE Dim_Composto (
    Composto_SK INT         NOT NULL PRIMARY KEY,
    Composto    VARCHAR(20) NOT NULL,
    Tipo_Piso   VARCHAR(15) NOT NULL        -- Seco, Chuva, Desconhecido
);
GO

-- ============================================================
-- TABELAS DE FACTOS
-- ============================================================

-- ----------------------------------------------------------
-- Fact_Performance
-- Grain: um registo por piloto por corrida (~27K linhas)
-- ----------------------------------------------------------
CREATE TABLE Fact_Performance (
    Data_SK                INT             NOT NULL,
    Piloto_SK              INT             NOT NULL,
    Circuito_SK            INT             NOT NULL,
    Construtor_SK          INT             NOT NULL,
    Pontos_Conquistados    DECIMAL(8,2)    NULL,
    Tempo_Total_Pit_Stops  DECIMAL(8,3)    NULL,     -- soma duracao pit stops (seg)
    Num_Pit_Stops          INT             NULL,
    Posicao_Partida        INT             NULL,
    Posicao_Final          INT             NULL,      -- NULL = DNF/DNS/Nao classificado
    Posicoes_Ganhas        INT             NULL,      -- grid - position; 0 se DNF
    Abandono_Mecanico      BIT             NULL       -- 1 se abandono mecanico
);
GO

-- ----------------------------------------------------------
-- Fact_Volta
-- Grain: um registo por piloto por corrida por volta (~873K linhas)
-- ----------------------------------------------------------
CREATE TABLE Fact_Volta (
    Data_SK         INT             NOT NULL,
    Piloto_SK       INT             NOT NULL,
    Circuito_SK     INT             NOT NULL,
    Construtor_SK   INT             NOT NULL,
    Composto_SK     INT             NOT NULL,         -- 1 = Desconhecido (pre-2024)
    Num_Volta       INT             NOT NULL,         -- dimensao degenerada
    Stint           INT             NULL,             -- numero do stint (2024+)
    Tempo_Volta_ms  INT             NULL,             -- tempo da volta em ms
    Tempo_S1        DECIMAL(8,3)    NULL,             -- setor 1 (2024+)
    Tempo_S2        DECIMAL(8,3)    NULL,             -- setor 2 (2024+)
    Tempo_S3        DECIMAL(8,3)    NULL,             -- setor 3 (2024+)
    Posicao_na_Volta INT            NULL,             -- posicao no momento da volta
    Volta_Sob_SC    BIT             NULL,             -- 1 se volta sob safety car
    Paragem_Box     BIT             NULL              -- 1 se paragem nas boxes nesta volta
);
GO

PRINT 'Tabelas do F1_DW criadas com sucesso.';
GO
