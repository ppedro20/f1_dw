-- ═══════════════════════════════════════════════════════════════
-- ETL · dim_construtor
-- SSIS: OLE DB Source (f1_operacional) → Derived Column → SCD → dim_construtor (f1_dw)
-- ═══════════════════════════════════════════════════════════════
SELECT
    c.constructorId                                 AS nk_construtor,
    c.name                                          AS nome,
    c.nationality                                   AS nacionalidade
    -- pais: adicionar com Derived Column no SSIS (mapeamento de nationality → país)
FROM dbo.constructors c;

-- Derived Column expression para pais:
-- (nationality == "British") ? "United Kingdom" :
-- (nationality == "American") ? "United States" :
-- (nationality == "Italian") ? "Italy" :
-- (nationality == "German") ? "Germany" :
-- (nationality == "French") ? "France" :
-- (nationality == "Austrian") ? "Austria" :
-- (nationality == "Dutch") ? "Netherlands" :
-- nationality

-- SCD: nk_construtor = Business Key; nome, nacionalidade, pais = Fixed Attributes
