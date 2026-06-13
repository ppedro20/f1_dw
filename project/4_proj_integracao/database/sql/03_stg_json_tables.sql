-- ============================================================
-- F1_DB - Tabelas JSON (Telemetria e Sessao)
-- ============================================================
-- Tabelas para dados provenientes de ficheiros JSON
-- (apenas sessoes do tipo 'Race' - ver ETL).
-- ============================================================

USE F1_DB;
GO

-- ----------------------------------------------------------
-- sessions
-- Tabela mae referenciada por todas as tabelas JSON.
-- Povoada a partir da estrutura de diretorios:
--   {ano}/{Grande Premio}/{Sessao}/
-- ----------------------------------------------------------
CREATE TABLE sessions (
    session_id  INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    ano         INT              NOT NULL,
    gp          VARCHAR(100)     NOT NULL,
    sessao      VARCHAR(50)      NOT NULL,
    CONSTRAINT UQ_sessions UNIQUE (ano, gp, sessao)
);

-- ----------------------------------------------------------
-- weather
-- Fonte: {ano}/{GP}/{sessao}/weather.json
-- Arrays paralelos indexados por timestamp.
-- ----------------------------------------------------------
CREATE TABLE weather (
    weather_id   INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    session_id   INT            NOT NULL,
    reading_idx  INT            NOT NULL,
    timestamp_s  DECIMAL(10,3)  NOT NULL,
    track_temp   DECIMAL(4,1)   NULL,
    air_temp     DECIMAL(4,1)   NULL,
    humidity     DECIMAL(5,1)   NULL,
    wind_speed   DECIMAL(4,1)   NULL,
    wind_dir     INT            NULL,
    CONSTRAINT FK_weather_session FOREIGN KEY (session_id)
        REFERENCES sessions(session_id)
);

-- ----------------------------------------------------------
-- session_drivers
-- Fonte: {ano}/{GP}/{sessao}/drivers.json
-- Lista de pilotos participantes na sessao.
-- ----------------------------------------------------------
CREATE TABLE session_drivers (
    session_driver_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    session_id        INT            NOT NULL,
    driver_code       VARCHAR(3)     NOT NULL,
    team              VARCHAR(100)   NOT NULL,
    driver_number     INT            NOT NULL,
    first_name        VARCHAR(50)    NOT NULL,
    last_name         VARCHAR(50)    NOT NULL,
    CONSTRAINT FK_session_drivers_session FOREIGN KEY (session_id)
        REFERENCES sessions(session_id)
);

-- ----------------------------------------------------------
-- session_corners
-- Fonte: {ano}/{GP}/{sessao}/corners.json
-- Metadados das curvas do circuito.
-- ----------------------------------------------------------
CREATE TABLE session_corners (
    corner_id     INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    session_id    INT            NOT NULL,
    corner_number INT            NOT NULL,
    x             DECIMAL(12,6)  NOT NULL,
    y             DECIMAL(12,6)  NOT NULL,
    distance      DECIMAL(12,6)  NOT NULL,
    angle         DECIMAL(8,4)   NOT NULL,
    rotation      DECIMAL(8,4)   NOT NULL,
    CONSTRAINT FK_session_corners_session FOREIGN KEY (session_id)
        REFERENCES sessions(session_id)
);

-- ----------------------------------------------------------
-- race_control_msgs
-- Fonte: {ano}/{GP}/{sessao}/rcm.json
-- Mensagens da direcao de prova (bandeiras, penalidades, SC).
-- ----------------------------------------------------------
CREATE TABLE race_control_msgs (
    rcm_id        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    session_id    INT            NOT NULL,
    timestamp     DATETIME2      NOT NULL,
    category      VARCHAR(50)    NULL,
    flag          VARCHAR(20)    NULL,
    lap           INT            NULL,
    message       VARCHAR(1000)  NULL,
    scope         VARCHAR(50)    NULL,
    sector        INT            NULL,
    driver_number INT            NULL,
    CONSTRAINT FK_rcm_session FOREIGN KEY (session_id)
        REFERENCES sessions(session_id)
);

-- ----------------------------------------------------------
-- driver_laptimes
-- Fonte: {ano}/{GP}/{sessao}/{codigo}/laptimes.json
-- Tempos de volta, compostos, setores por piloto.
-- ----------------------------------------------------------
CREATE TABLE driver_laptimes (
    lap_id        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    session_id    INT            NOT NULL,
    driver_code   VARCHAR(3)     NOT NULL,
    time_s        DECIMAL(8,3)   NULL,
    lap           INT            NOT NULL,
    compound      VARCHAR(20)    NULL,
    stint         INT            NULL,
    s1            DECIMAL(8,3)   NULL,
    s2            DECIMAL(8,3)   NULL,
    s3            DECIMAL(8,3)   NULL,
    position      INT            NULL,
    life          INT            NULL,
    fresh         BIT            NULL,
    status        INT            NULL,
    pout          DECIMAL(8,3)   NULL,
    pin           DECIMAL(8,3)   NULL,
    iacc          BIT            NULL,
    CONSTRAINT FK_driver_laptimes_session FOREIGN KEY (session_id)
        REFERENCES sessions(session_id)
);

-- ----------------------------------------------------------
-- telemetry
-- Fonte: {ano}/{GP}/{sessao}/{codigo}/{n}_tel.json
-- Telemetria de alta frequencia por volta (apenas corridas).
-- ----------------------------------------------------------
CREATE TABLE telemetry (
    tel_id        INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    session_id    INT            NOT NULL,
    driver_code   VARCHAR(3)     NOT NULL,
    lap           INT            NOT NULL,
    time_s        DECIMAL(8,3)   NOT NULL,
    speed         DECIMAL(8,3)   NULL,
    rpm           DECIMAL(10,4)  NULL,
    gear          INT            NULL,
    throttle      DECIMAL(5,1)   NULL,
    brake         BIT            NULL,
    drs           BIT            NULL,
    distance      DECIMAL(10,4)  NULL,
    x             DECIMAL(12,6)  NULL,
    y             DECIMAL(12,6)  NULL,
    z             DECIMAL(12,6)  NULL,
    CONSTRAINT FK_telemetry_session FOREIGN KEY (session_id)
        REFERENCES sessions(session_id)
);

-- ----------------------------------------------------------
-- virtual_safety_car
-- Fonte: virtual_safety_car_estimates.json
-- Array de voltas sob VSC por Grande Premio, normalizado.
-- ----------------------------------------------------------
CREATE TABLE virtual_safety_car (
    vsc_id      INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
    race_name   VARCHAR(150) NOT NULL,
    lap_number  INT          NOT NULL
);

PRINT 'Tabelas JSON criadas com sucesso.';
GO
