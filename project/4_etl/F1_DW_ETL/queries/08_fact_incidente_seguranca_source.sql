-- ═══════════════════════════════════════════════════════════════
-- ETL · fact_incidente_seguranca
-- Fontes: safety_cars, red_flags, fatal_accidents_drivers, fatal_accidents_marshalls
-- NOTA: safety_cars e red_flags ligam a races por nome — sem FK formal.
--       Usar a query abaixo que faz o join por nome+ano.
-- Parâmetro: ? = User::LAST_INCIDENTE_ID
-- ═══════════════════════════════════════════════════════════════

-- ─── SAFETY CARS ───────────────────────────────────────────────
SELECT
    ROW_NUMBER() OVER (ORDER BY sc.[Race], sc.[Season], sc.[Deployed]) AS nk_incidente,
    CONVERT(INT, CONVERT(VARCHAR(8), ra.date, 112))  AS sk_data,
    dci.sk_circuito,
    dr.sk_corrida,
    'Safety Car'                                     AS tipo_incidente,
    sc.[Deployed]                                    AS volta_inicio,
    sc.[Retreated]                                   AS volta_fim,
    sc.[FullLaps]                                    AS voltas_neutralizadas,
    CAST(0 AS BIT)                                   AS fatal
FROM f1_operacional.dbo.safety_cars sc
JOIN f1_operacional.dbo.races ra
    ON ra.year = sc.[Season]
    AND ra.name LIKE '%' + REPLACE(sc.[Race], ' Grand Prix','') + '%'
JOIN f1_dw.dbo.dim_circuito  dci ON dci.nk_circuito = ra.circuitId
JOIN f1_dw.dbo.dim_corrida   dr  ON dr.nk_corrida   = ra.raceId

UNION ALL

-- ─── RED FLAGS ─────────────────────────────────────────────────
SELECT
    100000 + ROW_NUMBER() OVER (ORDER BY rf.[Race], rf.[Season], rf.[Lap]),
    CONVERT(INT, CONVERT(VARCHAR(8), ra.date, 112)),
    dci.sk_circuito,
    dr.sk_corrida,
    'Red Flag',
    rf.[Lap],
    NULL,
    NULL,
    CAST(0 AS BIT)
FROM f1_operacional.dbo.red_flags rf
JOIN f1_operacional.dbo.races ra
    ON ra.year = rf.[Season]
    AND ra.name LIKE '%' + REPLACE(rf.[Race], ' Grand Prix','') + '%'
JOIN f1_dw.dbo.dim_circuito  dci ON dci.nk_circuito = ra.circuitId
JOIN f1_dw.dbo.dim_corrida   dr  ON dr.nk_corrida   = ra.raceId

UNION ALL

-- ─── ACIDENTES FATAIS (PILOTOS) ────────────────────────────────
SELECT
    200000 + ROW_NUMBER() OVER (ORDER BY fa.[Driver], fa.[Date]),
    CONVERT(INT, CONVERT(VARCHAR(8),
        TRY_CAST(fa.[Date] AS DATE), 112))           AS sk_data,
    dci.sk_circuito,
    dr.sk_corrida,
    'Fatal',
    NULL, NULL, NULL,
    CAST(1 AS BIT)
FROM f1_operacional.dbo.fatal_accidents_drivers fa
LEFT JOIN f1_operacional.dbo.races ra
    ON ra.name LIKE '%' + ISNULL(fa.[Grand Prix],'') + '%'
    AND ra.year = YEAR(TRY_CAST(fa.[Date] AS DATE))
LEFT JOIN f1_dw.dbo.dim_circuito  dci ON dci.nk_circuito = ra.circuitId
LEFT JOIN f1_dw.dbo.dim_corrida   dr  ON dr.nk_corrida   = ra.raceId

UNION ALL

-- ─── ACIDENTES FATAIS (COMISSÁRIOS) ────────────────────────────
SELECT
    300000 + ROW_NUMBER() OVER (ORDER BY fm.[Name], fm.[Date]),
    CONVERT(INT, CONVERT(VARCHAR(8),
        TRY_CAST(fm.[Date] AS DATE), 112)),
    dci.sk_circuito,
    dr.sk_corrida,
    'Fatal',
    NULL, NULL, NULL,
    CAST(1 AS BIT)
FROM f1_operacional.dbo.fatal_accidents_marshalls fm
LEFT JOIN f1_operacional.dbo.races ra
    ON ra.name LIKE '%' + ISNULL(fm.[Grand Prix],'') + '%'
    AND ra.year = YEAR(TRY_CAST(fm.[Date] AS DATE))
LEFT JOIN f1_dw.dbo.dim_circuito  dci ON dci.nk_circuito = ra.circuitId
LEFT JOIN f1_dw.dbo.dim_corrida   dr  ON dr.nk_corrida   = ra.raceId;

-- Destination: f1_dw.dbo.fact_incidente_seguranca
-- Nota: nk_incidente > ? filtra para carga incremental (usar subquery se necessário)
