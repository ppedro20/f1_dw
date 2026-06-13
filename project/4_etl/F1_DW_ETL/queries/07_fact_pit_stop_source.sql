-- ═══════════════════════════════════════════════════════════════
-- ETL · fact_pit_stop  (dados disponíveis desde 2011)
-- SSIS: OLE DB Source (f1_operacional, cross-db join) → OLE DB Destination (f1_dw)
-- Parâmetro: ? = User::LAST_PITSTOP_ID
-- ═══════════════════════════════════════════════════════════════
SELECT
    ps.raceId * 1000 + ps.driverId * 10 + ps.stop            AS nk_pit_stop,

    CONVERT(INT, CONVERT(VARCHAR(8), ra.date, 112))           AS sk_data,
    dp.sk_piloto,
    dc.sk_construtor,
    dr.sk_corrida,

    ps.stop                                                   AS numero_paragem,
    ps.lap                                                    AS volta,
    ps.milliseconds                                           AS duracao_ms

FROM f1_operacional.dbo.pit_stops ps
JOIN f1_operacional.dbo.races     ra ON ra.raceId        = ps.raceId
JOIN f1_dw.dbo.dim_piloto         dp ON dp.nk_piloto     = ps.driverId
JOIN f1_dw.dbo.dim_corrida        dr ON dr.nk_corrida    = ps.raceId
JOIN f1_dw.dbo.dim_construtor     dc ON dc.nk_construtor =
    (SELECT constructorId FROM f1_operacional.dbo.results
     WHERE raceId = ps.raceId AND driverId = ps.driverId)

WHERE (ps.raceId * 1000 + ps.driverId * 10 + ps.stop) > ?;

-- Destination: f1_dw.dbo.fact_pit_stop
