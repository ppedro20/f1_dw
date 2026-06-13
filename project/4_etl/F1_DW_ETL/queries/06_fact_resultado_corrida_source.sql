-- ═══════════════════════════════════════════════════════════════
-- ETL · fact_resultado_corrida
-- SSIS: OLE DB Source (f1_operacional, cross-db join) → OLE DB Destination (f1_dw)
-- Conexão: f1_operacional | SQL Command
-- Parâmetro: ? = User::LAST_RESULTADO_ID (OLE DB: usa ? como placeholder)
-- ═══════════════════════════════════════════════════════════════
SELECT
    res.resultId                                                     AS nk_resultado,

    -- sk_data: converter date → YYYYMMDD INT
    CONVERT(INT, CONVERT(VARCHAR(8), ra.date, 112))                  AS sk_data,

    -- sk_* via lookup nas dimensões do DW
    dp.sk_piloto,
    dc.sk_construtor,
    dci.sk_circuito,
    dr.sk_corrida,
    de.sk_estado,

    -- medidas
    ISNULL(CAST(res.points AS DECIMAL(6,2)), 0)                     AS pontos,
    res.grid                                                         AS posicao_grid,
    res.position                                                     AS posicao_final,
    CASE WHEN res.grid IS NOT NULL AND res.position IS NOT NULL
         THEN res.grid - res.position ELSE NULL END                  AS posicoes_ganhas,
    res.laps                                                         AS voltas_completadas,
    res.milliseconds                                                 AS tempo_corrida_ms,

    -- fastestLapTime "1:23.456" → ms
    CASE WHEN res.fastestLapTime IS NOT NULL AND res.fastestLapTime <> ''
         THEN
             (CAST(LEFT(res.fastestLapTime,
                   CHARINDEX(':', res.fastestLapTime)-1) AS INT) * 60000)
           + (CAST(SUBSTRING(res.fastestLapTime,
                   CHARINDEX(':', res.fastestLapTime)+1,
                   CHARINDEX('.', res.fastestLapTime)
                   - CHARINDEX(':', res.fastestLapTime)-1) AS INT) * 1000)
           + CAST(RIGHT(res.fastestLapTime,
                   LEN(res.fastestLapTime)
                   - CHARINDEX('.', res.fastestLapTime)) AS INT)
         ELSE NULL END                                               AS tempo_volta_rapida_ms,

    CAST(res.fastestLapSpeed AS DECIMAL(6,3))                       AS velocidade_volta_rapida

FROM f1_operacional.dbo.results   res
JOIN f1_operacional.dbo.races     ra  ON ra.raceId          = res.raceId
JOIN f1_dw.dbo.dim_piloto         dp  ON dp.nk_piloto       = res.driverId
JOIN f1_dw.dbo.dim_construtor     dc  ON dc.nk_construtor   = res.constructorId
JOIN f1_dw.dbo.dim_circuito       dci ON dci.nk_circuito    = ra.circuitId
JOIN f1_dw.dbo.dim_corrida        dr  ON dr.nk_corrida      = res.raceId
JOIN f1_dw.dbo.dim_estado         de  ON de.nk_estado       = res.statusId

WHERE res.resultId > ?;

-- Destination: f1_dw.dbo.fact_resultado_corrida
-- Mapeamento direto de todas as colunas acima
