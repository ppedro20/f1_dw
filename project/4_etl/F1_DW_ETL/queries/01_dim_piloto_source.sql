-- ═══════════════════════════════════════════════════════════════
-- ETL · dim_piloto
-- SSIS: OLE DB Source (f1_operacional) → SCD → dim_piloto (f1_dw)
-- ═══════════════════════════════════════════════════════════════
SELECT
    d.driverId                                      AS nk_piloto,
    d.forename + ' ' + d.surname                    AS nome_completo,
    d.code                                          AS codigo,
    d.number                                        AS numero,
    d.dob                                           AS data_nascimento,
    d.nationality                                   AS nacionalidade
FROM dbo.drivers d;

-- SCD: nk_piloto = Business Key
--      nome_completo, codigo, numero = Fixed Attributes
--      nacionalidade = Fixed Attribute
