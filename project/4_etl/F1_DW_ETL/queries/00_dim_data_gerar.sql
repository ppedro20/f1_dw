-- ═══════════════════════════════════════════════════════════════
-- ETL · dim_data — Geração de datas 1950-01-01 a 2030-12-31
-- Executar DIRETAMENTE em SSMS na base f1_dw (não via SSIS Source)
-- ═══════════════════════════════════════════════════════════════
TRUNCATE TABLE dbo.dim_data;

WITH datas AS (
    SELECT CAST('1950-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d) FROM datas WHERE d < '2030-12-31'
)
INSERT INTO dbo.dim_data (
    sk_data, data_completa, dia, dia_semana, num_semana,
    mes, nome_mes, trimestre, semestre, ano, epoca_f1
)
SELECT
    CONVERT(INT, CONVERT(VARCHAR(8), d, 112))                        AS sk_data,
    d                                                                AS data_completa,
    DAY(d)                                                           AS dia,
    DATENAME(WEEKDAY, d)                                             AS dia_semana,
    DATEPART(ISO_WEEK, d)                                            AS num_semana,
    MONTH(d)                                                         AS mes,
    DATENAME(MONTH, d)                                               AS nome_mes,
    DATEPART(QUARTER, d)                                             AS trimestre,
    CASE WHEN MONTH(d) <= 6 THEN 1 ELSE 2 END                       AS semestre,
    YEAR(d)                                                          AS ano,
    YEAR(d)                                                          AS epoca_f1
FROM datas
OPTION (MAXRECURSION 30000);
