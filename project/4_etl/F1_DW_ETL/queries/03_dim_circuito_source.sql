-- ═══════════════════════════════════════════════════════════════
-- ETL · dim_circuito
-- SSIS: OLE DB Source (f1_operacional) → Derived Column → SCD → dim_circuito (f1_dw)
-- ═══════════════════════════════════════════════════════════════
SELECT
    ci.circuitId                                    AS nk_circuito,
    ci.name                                         AS nome_circuito,
    ci.location                                     AS cidade,
    ci.country                                      AS pais,
    ci.lat                                          AS latitude,
    ci.lng                                          AS longitude
    -- continente: adicionar com Derived Column no SSIS
FROM dbo.circuits ci;

-- Derived Column expression para continente:
-- (pais == "UK" || pais == "Germany" || pais == "Italy" || pais == "France" ||
--  pais == "Spain" || pais == "Belgium" || pais == "Netherlands" || pais == "Austria" ||
--  pais == "Hungary" || pais == "Portugal" || pais == "Switzerland" || pais == "Sweden" ||
--  pais == "Finland" || pais == "Russia" || pais == "Azerbaijan") ? "Europa" :
-- (pais == "Australia") ? "Oceânia" :
-- (pais == "USA" || pais == "Canada" || pais == "Mexico") ? "América do Norte" :
-- (pais == "Brazil" || pais == "Argentina") ? "América do Sul" :
-- (pais == "Japan" || pais == "China" || pais == "Korea" || pais == "Singapore" ||
--  pais == "Bahrain" || pais == "UAE" || pais == "Saudi Arabia" || pais == "Qatar") ? "Ásia" :
-- "Outro"

-- SCD: nk_circuito = Business Key; todos os atributos = Fixed
