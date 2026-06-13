-- ═══════════════════════════════════════════════════════════════
-- ETL · dim_corrida
-- SSIS: OLE DB Source (f1_operacional) → SCD → dim_corrida (f1_dw)
-- ═══════════════════════════════════════════════════════════════
SELECT
    r.raceId                                        AS nk_corrida,
    r.name                                          AS nome_corrida,
    r.year                                          AS ano,
    r.round                                         AS ronda,
    CAST(CASE WHEN sr.raceId IS NOT NULL THEN 1 ELSE 0 END AS BIT) AS tem_sprint
FROM dbo.races r
LEFT JOIN (
    SELECT DISTINCT raceId FROM dbo.sprint_results
) sr ON sr.raceId = r.raceId;

-- SCD: nk_corrida = Business Key; todos os atributos = Fixed
