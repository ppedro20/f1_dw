-- ============================================================
-- F1_DB - Indices de Performance
-- ============================================================
-- Indices para otimizar joins entre tabelas CSV e JSON
-- durante o processo ETL.
-- ============================================================

USE F1_DB;
GO

-- ----------------------------------------------------------
-- Tabelas CSV
-- ----------------------------------------------------------

-- races
CREATE INDEX IX_races_year      ON races(year);
CREATE INDEX IX_races_circuitId ON races(circuitId);

-- results
CREATE INDEX IX_results_raceId        ON results(raceId);
CREATE INDEX IX_results_driverId      ON results(driverId);
CREATE INDEX IX_results_constructorId ON results(constructorId);
CREATE INDEX IX_results_statusId      ON results(statusId);

-- sprint_results
CREATE INDEX IX_sprint_results_raceId        ON sprint_results(raceId);
CREATE INDEX IX_sprint_results_driverId      ON sprint_results(driverId);
CREATE INDEX IX_sprint_results_constructorId ON sprint_results(constructorId);

-- lap_times
CREATE INDEX IX_lap_times_raceId   ON lap_times(raceId);
CREATE INDEX IX_lap_times_driverId ON lap_times(driverId);

-- pit_stops
CREATE INDEX IX_pit_stops_raceId   ON pit_stops(raceId);
CREATE INDEX IX_pit_stops_driverId ON pit_stops(driverId);

-- qualifying
CREATE INDEX IX_qualifying_raceId        ON qualifying(raceId);
CREATE INDEX IX_qualifying_driverId      ON qualifying(driverId);
CREATE INDEX IX_qualifying_constructorId ON qualifying(constructorId);

-- constructor_results
CREATE INDEX IX_constructor_results_raceId        ON constructor_results(raceId);
CREATE INDEX IX_constructor_results_constructorId ON constructor_results(constructorId);

-- constructor_standings
CREATE INDEX IX_constructor_standings_raceId        ON constructor_standings(raceId);
CREATE INDEX IX_constructor_standings_constructorId ON constructor_standings(constructorId);

-- driver_standings
CREATE INDEX IX_driver_standings_raceId   ON driver_standings(raceId);
CREATE INDEX IX_driver_standings_driverId ON driver_standings(driverId);

-- ----------------------------------------------------------
-- Tabelas JSON
-- ----------------------------------------------------------

-- weather
CREATE INDEX IX_weather_session_id ON weather(session_id);

-- session_drivers
CREATE INDEX IX_session_drivers_session_id  ON session_drivers(session_id);
CREATE INDEX IX_session_drivers_driver_code ON session_drivers(driver_code);

-- session_corners
CREATE INDEX IX_session_corners_session_id ON session_corners(session_id);

-- race_control_msgs
CREATE INDEX IX_rcm_session_id ON race_control_msgs(session_id);
CREATE INDEX IX_rcm_lap        ON race_control_msgs(lap);

-- driver_laptimes
CREATE INDEX IX_driver_laptimes_session_id  ON driver_laptimes(session_id);
CREATE INDEX IX_driver_laptimes_driver_code ON driver_laptimes(driver_code);
CREATE INDEX IX_driver_laptimes_lap         ON driver_laptimes(lap);
CREATE INDEX IX_driver_laptimes_compound    ON driver_laptimes(compound);

-- telemetry
CREATE INDEX IX_telemetry_session_id  ON telemetry(session_id);
CREATE INDEX IX_telemetry_driver_code ON telemetry(driver_code);
CREATE INDEX IX_telemetry_lap         ON telemetry(lap);
CREATE INDEX IX_telemetry_session_lap ON telemetry(session_id, driver_code, lap);

-- virtual_safety_car
CREATE INDEX IX_vsc_race_name ON virtual_safety_car(race_name);

PRINT 'Indices criados com sucesso.';
GO
