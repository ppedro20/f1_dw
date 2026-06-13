-- ============================================================
-- F1_DB - Tabelas CSV
-- ============================================================
-- Espelho dos 19 ficheiros CSV existentes em project/_data/.
-- Nomes e tipos de colunas mantidos conforme os ficheiros
-- originais. Valores '\N' nos CSVs serao carregados como NULL.
-- ============================================================

USE F1_DB;
GO

-- ----------------------------------------------------------
-- circuits
-- Fonte: circuits.csv (78 circuitos)
-- ----------------------------------------------------------
CREATE TABLE circuits (
    circuitId   INT           NOT NULL PRIMARY KEY,
    circuitRef  VARCHAR(50)   NOT NULL,
    name        VARCHAR(100)  NOT NULL,
    location    VARCHAR(100)  NULL,
    country     VARCHAR(50)   NULL,
    lat         DECIMAL(10,6) NULL,
    lng         DECIMAL(10,6) NULL,
    alt         INT           NULL,
    url         VARCHAR(255)  NULL
);

-- ----------------------------------------------------------
-- constructors
-- Fonte: constructors.csv (214 construtores)
-- ----------------------------------------------------------
CREATE TABLE constructors (
    constructorId   INT          NOT NULL PRIMARY KEY,
    constructorRef  VARCHAR(50)  NOT NULL,
    name            VARCHAR(100) NOT NULL,
    nationality     VARCHAR(50)  NULL,
    url             VARCHAR(255) NULL
);

-- ----------------------------------------------------------
-- drivers
-- Fonte: drivers.csv (865 pilotos)
-- ----------------------------------------------------------
CREATE TABLE drivers (
    driverId    INT          NOT NULL PRIMARY KEY,
    driverRef   VARCHAR(50)  NOT NULL,
    number      INT          NULL,
    code        VARCHAR(3)   NULL,
    forename    VARCHAR(50)  NOT NULL,
    surname     VARCHAR(50)  NOT NULL,
    dob         DATE         NULL,
    nationality VARCHAR(50)  NULL,
    url         VARCHAR(255) NULL
);

-- ----------------------------------------------------------
-- seasons
-- Fonte: seasons.csv (77 epocas, 1950-2026)
-- ----------------------------------------------------------
CREATE TABLE seasons (
    year INT          NOT NULL PRIMARY KEY,
    url  VARCHAR(255) NULL
);

-- ----------------------------------------------------------
-- status
-- Fonte: status.csv (140 estados de termino)
-- ----------------------------------------------------------
CREATE TABLE status (
    statusId INT           NOT NULL PRIMARY KEY,
    status   VARCHAR(100)  NOT NULL
);

-- ----------------------------------------------------------
-- races
-- Fonte: races.csv (1171 corridas, 1950-2026)
-- ----------------------------------------------------------
CREATE TABLE races (
    raceId      INT          NOT NULL PRIMARY KEY,
    year        INT          NOT NULL,
    round       INT          NOT NULL,
    circuitId   INT          NOT NULL,
    name        VARCHAR(100) NOT NULL,
    date        DATE         NOT NULL,
    time        TIME         NULL,
    url         VARCHAR(255) NULL,
    fp1_date    DATE         NULL,
    fp1_time    TIME         NULL,
    fp2_date    DATE         NULL,
    fp2_time    TIME         NULL,
    fp3_date    DATE         NULL,
    fp3_time    TIME         NULL,
    quali_date  DATE         NULL,
    quali_time  TIME         NULL,
    sprint_date DATE         NULL,
    sprint_time TIME         NULL
);

-- ----------------------------------------------------------
-- results
-- Fonte: results.csv (27370 registos, 1950-2026)
-- ----------------------------------------------------------
CREATE TABLE results (
    resultId        INT            NOT NULL PRIMARY KEY,
    raceId          INT            NOT NULL,
    driverId        INT            NOT NULL,
    constructorId   INT            NOT NULL,
    number          INT            NULL,
    grid            INT            NULL,
    position        INT            NULL,
    positionText    VARCHAR(10)    NOT NULL,
    positionOrder   INT            NOT NULL,
    points          DECIMAL(8,2)   NOT NULL,
    laps            INT            NOT NULL,
    time            VARCHAR(30)    NULL,
    milliseconds    INT            NULL,
    fastestLap      INT            NULL,
    rank            INT            NULL,
    fastestLapTime  VARCHAR(20)    NULL,
    fastestLapSpeed DECIMAL(8,3)   NULL,
    statusId        INT            NOT NULL
);

-- ----------------------------------------------------------
-- sprint_results
-- Fonte: sprint_results.csv (546 registos, 2021-2026)
-- ----------------------------------------------------------
CREATE TABLE sprint_results (
    resultId        INT            NOT NULL PRIMARY KEY,
    raceId          INT            NOT NULL,
    driverId        INT            NOT NULL,
    constructorId   INT            NOT NULL,
    number          INT            NOT NULL,
    grid            INT            NOT NULL,
    position        INT            NULL,
    positionText    VARCHAR(10)    NOT NULL,
    positionOrder   INT            NOT NULL,
    points          DECIMAL(8,2)   NOT NULL,
    laps            INT            NOT NULL,
    time            VARCHAR(30)    NULL,
    milliseconds    INT            NULL,
    fastestLap      INT            NULL,
    fastestLapTime  VARCHAR(20)    NULL,
    statusId        INT            NULL,
    rank            INT            NULL
);

-- ----------------------------------------------------------
-- lap_times
-- Fonte: lap_times.csv (872521 registos, 1996-2026)
-- Chave primaria composta: (raceId, driverId, lap)
-- ----------------------------------------------------------
CREATE TABLE lap_times (
    raceId       INT          NOT NULL,
    driverId     INT          NOT NULL,
    lap          INT          NOT NULL,
    position     INT          NOT NULL,
    time         VARCHAR(20)  NULL,
    milliseconds INT          NULL,
    CONSTRAINT PK_lap_times PRIMARY KEY (raceId, driverId, lap)
);

-- ----------------------------------------------------------
-- pit_stops
-- Fonte: pit_stops.csv (22335 registos, 2011-2026)
-- Chave primaria composta: (raceId, driverId, stop)
-- ----------------------------------------------------------
CREATE TABLE pit_stops (
    raceId       INT            NOT NULL,
    driverId     INT            NOT NULL,
    stop         INT            NOT NULL,
    lap          INT            NOT NULL,
    time         TIME           NOT NULL,
    duration     DECIMAL(8,3)   NULL,
    milliseconds INT            NULL,
    CONSTRAINT PK_pit_stops PRIMARY KEY (raceId, driverId, stop)
);

-- ----------------------------------------------------------
-- qualifying
-- Fonte: qualifying.csv (11102 registos, 2003-2026)
-- ----------------------------------------------------------
CREATE TABLE qualifying (
    qualifyId     INT          NOT NULL PRIMARY KEY,
    raceId        INT          NOT NULL,
    driverId      INT          NOT NULL,
    constructorId INT          NOT NULL,
    number        INT          NOT NULL,
    position      INT          NOT NULL,
    q1            VARCHAR(20)  NULL,
    q2            VARCHAR(20)  NULL,
    q3            VARCHAR(20)  NULL
);

-- ----------------------------------------------------------
-- constructor_results
-- Fonte: constructor_results.csv (12931 registos, 1958-2026)
-- ----------------------------------------------------------
CREATE TABLE constructor_results (
    constructorResultsId INT          NOT NULL PRIMARY KEY,
    raceId               INT          NOT NULL,
    constructorId        INT          NOT NULL,
    points               DECIMAL(8,2) NULL,
    status               VARCHAR(20)  NULL
);

-- ----------------------------------------------------------
-- constructor_standings
-- Fonte: constructor_standings.csv (13697 registos, 1958-2026)
-- ----------------------------------------------------------
CREATE TABLE constructor_standings (
    constructorStandingsId INT          NOT NULL PRIMARY KEY,
    raceId                 INT          NOT NULL,
    constructorId          INT          NOT NULL,
    points                 DECIMAL(8,2) NOT NULL,
    position               INT          NULL,
    positionText           VARCHAR(10)  NULL,
    wins                   INT          NOT NULL
);

-- ----------------------------------------------------------
-- driver_standings
-- Fonte: driver_standings.csv (35493 registos, 1950-2026)
-- ----------------------------------------------------------
CREATE TABLE driver_standings (
    driverStandingsId INT          NOT NULL PRIMARY KEY,
    raceId            INT          NOT NULL,
    driverId          INT          NOT NULL,
    points            DECIMAL(8,2) NOT NULL,
    position          INT          NULL,
    positionText      VARCHAR(10)  NULL,
    wins              INT          NOT NULL
);

-- ----------------------------------------------------------
-- safety_cars
-- Fonte: safety_cars.csv (370 registos, 1973-2024)
-- ----------------------------------------------------------
CREATE TABLE safety_cars (
    Race       VARCHAR(100)  NOT NULL,
    Cause      VARCHAR(100)  NOT NULL,
    Deployed   INT           NOT NULL,
    Retreated  DECIMAL(5,1)  NULL,
    FullLaps   INT           NULL
);

-- ----------------------------------------------------------
-- red_flags
-- Fonte: red_flags.csv (99 registos, 1950-2024)
-- ----------------------------------------------------------
CREATE TABLE red_flags (
    Race     VARCHAR(100) NOT NULL,
    Lap      INT          NOT NULL,
    Resumed  VARCHAR(5)   NOT NULL,
    Incident TEXT         NULL,
    Excluded TEXT         NULL
);

-- ----------------------------------------------------------
-- fatal_accidents_drivers
-- Fonte: fatal_accidents_drivers.csv (51 registos, 1952-2015)
-- ----------------------------------------------------------
CREATE TABLE fatal_accidents_drivers (
    Driver           VARCHAR(100) NOT NULL,
    Age              INT          NOT NULL,
    DateOfAccident   DATE         NOT NULL,
    Event            VARCHAR(100) NOT NULL,
    Car              VARCHAR(100) NULL,
    Session          VARCHAR(50)  NOT NULL
);

-- ----------------------------------------------------------
-- fatal_accidents_marshalls
-- Fonte: fatal_accidents_marshalls.csv (5 registos, 1963-2001)
-- ----------------------------------------------------------
CREATE TABLE fatal_accidents_marshalls (
    Name             VARCHAR(100) NOT NULL,
    Age              INT          NOT NULL,
    DateOfAccident   DATE         NOT NULL,
    Event            VARCHAR(100) NOT NULL
);

PRINT 'Tabelas CSV criadas com sucesso.';
GO
