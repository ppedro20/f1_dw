-- ═══════════════════════════════════════════════════════════════════
-- F1 Data Warehouse — Criação do schema
-- Executar em SSMS ligado a localhost com o utilizador sa
-- ═══════════════════════════════════════════════════════════════════

-- ── 1. Criar base de dados ───────────────────────────────────────
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'f1_dw')
    CREATE DATABASE f1_dw;
GO

USE f1_dw;
GO

-- ── 2. Remover tabelas existentes (ordem inversa das FK) ─────────
IF OBJECT_ID('dbo.fact_incidente_seguranca', 'U') IS NOT NULL DROP TABLE dbo.fact_incidente_seguranca;
IF OBJECT_ID('dbo.fact_pit_stop',            'U') IS NOT NULL DROP TABLE dbo.fact_pit_stop;
IF OBJECT_ID('dbo.fact_resultado_corrida',   'U') IS NOT NULL DROP TABLE dbo.fact_resultado_corrida;
IF OBJECT_ID('dbo.dim_estado',               'U') IS NOT NULL DROP TABLE dbo.dim_estado;
IF OBJECT_ID('dbo.dim_corrida',              'U') IS NOT NULL DROP TABLE dbo.dim_corrida;
IF OBJECT_ID('dbo.dim_circuito',             'U') IS NOT NULL DROP TABLE dbo.dim_circuito;
IF OBJECT_ID('dbo.dim_construtor',           'U') IS NOT NULL DROP TABLE dbo.dim_construtor;
IF OBJECT_ID('dbo.dim_piloto',               'U') IS NOT NULL DROP TABLE dbo.dim_piloto;
IF OBJECT_ID('dbo.dim_data',                 'U') IS NOT NULL DROP TABLE dbo.dim_data;
GO

-- ═══════════════════════════════════════════════════════════════════
-- DIMENSÕES
-- ═══════════════════════════════════════════════════════════════════

-- ── dim_data ─────────────────────────────────────────────────────
-- sk_data = YYYYMMDD (ex: 20090329). Gerada por script SQL (ver popular_dim_data.sql)
CREATE TABLE dbo.dim_data (
    sk_data         INT          NOT NULL,
    data_completa   DATE         NOT NULL,
    dia             SMALLINT     NOT NULL,
    dia_semana      VARCHAR(15)  NOT NULL,
    num_semana      SMALLINT     NOT NULL,
    mes             SMALLINT     NOT NULL,
    nome_mes        VARCHAR(15)  NOT NULL,
    trimestre       SMALLINT     NOT NULL,
    semestre        SMALLINT     NOT NULL,
    ano             SMALLINT     NOT NULL,
    epoca_f1        SMALLINT     NOT NULL,
    CONSTRAINT PK_dim_data PRIMARY KEY (sk_data)
);
GO

-- ── dim_piloto ───────────────────────────────────────────────────
CREATE TABLE dbo.dim_piloto (
    sk_piloto           INT          NOT NULL IDENTITY(1,1),
    nk_piloto           INT          NOT NULL,
    nome_completo       VARCHAR(60)  NOT NULL,
    codigo              CHAR(3)      NULL,
    numero              SMALLINT     NULL,
    data_nascimento     DATE         NULL,
    nacionalidade       VARCHAR(30)  NULL,
    CONSTRAINT PK_dim_piloto PRIMARY KEY (sk_piloto)
);
GO

-- ── dim_construtor ───────────────────────────────────────────────
CREATE TABLE dbo.dim_construtor (
    sk_construtor   INT          NOT NULL IDENTITY(1,1),
    nk_construtor   INT          NOT NULL,
    nome            VARCHAR(50)  NOT NULL,
    nacionalidade   VARCHAR(30)  NULL,
    pais            VARCHAR(50)  NULL,
    CONSTRAINT PK_dim_construtor PRIMARY KEY (sk_construtor)
);
GO

-- ── dim_circuito ─────────────────────────────────────────────────
CREATE TABLE dbo.dim_circuito (
    sk_circuito     INT             NOT NULL IDENTITY(1,1),
    nk_circuito     INT             NOT NULL,
    nome_circuito   VARCHAR(100)    NOT NULL,
    cidade          VARCHAR(50)     NULL,
    pais            VARCHAR(50)     NULL,
    continente      VARCHAR(20)     NULL,
    latitude        DECIMAL(10,6)   NULL,
    longitude       DECIMAL(10,6)   NULL,
    CONSTRAINT PK_dim_circuito PRIMARY KEY (sk_circuito)
);
GO

-- ── dim_corrida ──────────────────────────────────────────────────
CREATE TABLE dbo.dim_corrida (
    sk_corrida      INT          NOT NULL IDENTITY(1,1),
    nk_corrida      INT          NOT NULL,
    nome_corrida    VARCHAR(60)  NOT NULL,
    ano             SMALLINT     NOT NULL,
    ronda           SMALLINT     NOT NULL,
    tem_sprint      BIT          NOT NULL DEFAULT 0,
    CONSTRAINT PK_dim_corrida PRIMARY KEY (sk_corrida)
);
GO

-- ── dim_estado ───────────────────────────────────────────────────
CREATE TABLE dbo.dim_estado (
    sk_estado   INT          NOT NULL IDENTITY(1,1),
    nk_estado   INT          NOT NULL,
    descricao   VARCHAR(50)  NOT NULL,
    categoria   VARCHAR(20)  NOT NULL,
    CONSTRAINT PK_dim_estado PRIMARY KEY (sk_estado)
);
GO

-- ═══════════════════════════════════════════════════════════════════
-- FACTOS
-- ═══════════════════════════════════════════════════════════════════

-- ── fact_resultado_corrida ───────────────────────────────────────
-- Granularidade: 1 linha por piloto por corrida
-- Fonte: results + races (f1_operacional)
CREATE TABLE dbo.fact_resultado_corrida (
    sk_resultado            INT             NOT NULL IDENTITY(1,1),
    nk_resultado            INT             NOT NULL,   -- results.resultId

    -- chaves surrogate
    sk_data                 INT             NOT NULL,
    sk_piloto               INT             NOT NULL,
    sk_construtor           INT             NOT NULL,
    sk_circuito             INT             NOT NULL,
    sk_corrida              INT             NOT NULL,
    sk_estado               INT             NOT NULL,

    -- medidas
    pontos                  DECIMAL(6,2)    NULL,
    posicao_grid            SMALLINT        NULL,
    posicao_final           SMALLINT        NULL,
    posicoes_ganhas         SMALLINT        NULL,       -- calculado: grid - final
    voltas_completadas      SMALLINT        NULL,
    tempo_corrida_ms        INT             NULL,
    tempo_volta_rapida_ms   INT             NULL,       -- convertido de MM:SS.mmm
    velocidade_volta_rapida DECIMAL(6,3)    NULL,       -- km/h

    CONSTRAINT PK_fact_resultado_corrida PRIMARY KEY (sk_resultado),
    CONSTRAINT FK_frc_data       FOREIGN KEY (sk_data)       REFERENCES dbo.dim_data       (sk_data),
    CONSTRAINT FK_frc_piloto     FOREIGN KEY (sk_piloto)     REFERENCES dbo.dim_piloto     (sk_piloto),
    CONSTRAINT FK_frc_construtor FOREIGN KEY (sk_construtor) REFERENCES dbo.dim_construtor (sk_construtor),
    CONSTRAINT FK_frc_circuito   FOREIGN KEY (sk_circuito)   REFERENCES dbo.dim_circuito   (sk_circuito),
    CONSTRAINT FK_frc_corrida    FOREIGN KEY (sk_corrida)    REFERENCES dbo.dim_corrida    (sk_corrida),
    CONSTRAINT FK_frc_estado     FOREIGN KEY (sk_estado)     REFERENCES dbo.dim_estado     (sk_estado)
);
GO

-- ── fact_pit_stop ────────────────────────────────────────────────
-- Granularidade: 1 linha por paragem por piloto por corrida
-- Fonte: pit_stops + races (disponível desde 2011)
CREATE TABLE dbo.fact_pit_stop (
    sk_pit_stop     INT         NOT NULL IDENTITY(1,1),
    nk_pit_stop     INT         NOT NULL,   -- raceId*1000 + driverId*10 + stop

    -- chaves surrogate
    sk_data         INT         NOT NULL,
    sk_piloto       INT         NOT NULL,
    sk_construtor   INT         NOT NULL,
    sk_corrida      INT         NOT NULL,

    -- medidas
    numero_paragem  SMALLINT    NOT NULL,   -- 1ª, 2ª, 3ª paragem na corrida
    volta           SMALLINT    NOT NULL,
    duracao_ms      INT         NULL,       -- 3 registos NULL nos dados originais

    CONSTRAINT PK_fact_pit_stop PRIMARY KEY (sk_pit_stop),
    CONSTRAINT FK_fps_data       FOREIGN KEY (sk_data)       REFERENCES dbo.dim_data       (sk_data),
    CONSTRAINT FK_fps_piloto     FOREIGN KEY (sk_piloto)     REFERENCES dbo.dim_piloto     (sk_piloto),
    CONSTRAINT FK_fps_construtor FOREIGN KEY (sk_construtor) REFERENCES dbo.dim_construtor (sk_construtor),
    CONSTRAINT FK_fps_corrida    FOREIGN KEY (sk_corrida)    REFERENCES dbo.dim_corrida    (sk_corrida)
);
GO

-- ── fact_incidente_seguranca ─────────────────────────────────────
-- Granularidade: 1 linha por incidente por corrida
-- Fontes: safety_cars, red_flags, fatal_accidents_drivers, fatal_accidents_marshalls
CREATE TABLE dbo.fact_incidente_seguranca (
    sk_incidente        INT             NOT NULL IDENTITY(1,1),
    nk_incidente        INT             NOT NULL,

    -- chaves surrogate
    sk_data             INT             NULL,   -- NULL para alguns acidentes fatais sem data exata
    sk_circuito         INT             NULL,
    sk_corrida          INT             NULL,

    -- medidas / descritores
    tipo_incidente      VARCHAR(20)     NOT NULL,   -- 'Safety Car' | 'Red Flag' | 'Fatal'
    volta_inicio        SMALLINT        NULL,
    volta_fim           SMALLINT        NULL,       -- NULL para Red Flag e Fatal
    voltas_neutralizadas SMALLINT       NULL,       -- só Safety Car
    fatal               BIT             NOT NULL DEFAULT 0,

    CONSTRAINT PK_fact_incidente PRIMARY KEY (sk_incidente),
    CONSTRAINT FK_fis_data     FOREIGN KEY (sk_data)     REFERENCES dbo.dim_data    (sk_data),
    CONSTRAINT FK_fis_circuito FOREIGN KEY (sk_circuito) REFERENCES dbo.dim_circuito(sk_circuito),
    CONSTRAINT FK_fis_corrida  FOREIGN KEY (sk_corrida)  REFERENCES dbo.dim_corrida (sk_corrida)
);
GO

-- ═══════════════════════════════════════════════════════════════════
-- ÍNDICES (performance analítica)
-- ═══════════════════════════════════════════════════════════════════

-- fact_resultado_corrida
CREATE INDEX IX_frc_piloto    ON dbo.fact_resultado_corrida (sk_piloto);
CREATE INDEX IX_frc_construtor ON dbo.fact_resultado_corrida (sk_construtor);
CREATE INDEX IX_frc_corrida   ON dbo.fact_resultado_corrida (sk_corrida);
CREATE INDEX IX_frc_data      ON dbo.fact_resultado_corrida (sk_data);
CREATE INDEX IX_frc_estado    ON dbo.fact_resultado_corrida (sk_estado);

-- fact_pit_stop
CREATE INDEX IX_fps_corrida   ON dbo.fact_pit_stop (sk_corrida);
CREATE INDEX IX_fps_piloto    ON dbo.fact_pit_stop (sk_piloto);

-- fact_incidente_seguranca
CREATE INDEX IX_fis_corrida   ON dbo.fact_incidente_seguranca (sk_corrida);
CREATE INDEX IX_fis_tipo      ON dbo.fact_incidente_seguranca (tipo_incidente);

-- dim_piloto (lookup por nk)
CREATE UNIQUE INDEX UX_dim_piloto_nk     ON dbo.dim_piloto     (nk_piloto);
CREATE UNIQUE INDEX UX_dim_construtor_nk ON dbo.dim_construtor (nk_construtor);
CREATE UNIQUE INDEX UX_dim_circuito_nk   ON dbo.dim_circuito   (nk_circuito);
CREATE UNIQUE INDEX UX_dim_corrida_nk    ON dbo.dim_corrida    (nk_corrida);
CREATE UNIQUE INDEX UX_dim_estado_nk     ON dbo.dim_estado     (nk_estado);
GO

PRINT 'f1_dw criada com sucesso.';
PRINT '  Dimensões: dim_data, dim_piloto, dim_construtor, dim_circuito, dim_corrida, dim_estado';
PRINT '  Factos:    fact_resultado_corrida, fact_pit_stop, fact_incidente_seguranca';
PRINT '';
PRINT 'Próximo passo: executar popular_dim_data.sql para gerar as datas 1950-2030';
GO
