-- ═══════════════════════════════════════════════════════════════
-- ETL · dim_estado
-- SSIS: OLE DB Source (f1_operacional) → Derived Column → SCD → dim_estado (f1_dw)
-- ═══════════════════════════════════════════════════════════════
SELECT
    s.statusId                                      AS nk_estado,
    s.status                                        AS descricao,
    CASE
        WHEN s.status = 'Finished'                  THEN 'Finished'
        WHEN s.status LIKE '+% Lap%'                THEN 'Lapped'
        WHEN s.status IN (
            'Engine','Gearbox','Hydraulics','Brakes','Transmission',
            'Electrical','Throttle','Clutch','Turbo','Suspension',
            'Wheel','Tyre','Vibrations','Water','Mechanical',
            'Driveshaft','Oil','Fuel system','Fire','Oil pressure',
            'Fuel pressure','Water pressure','Power Unit','ERS',
            'Electronics','Battery','Exhaust','Radiator','Overheating'
        )                                           THEN 'Mechanical'
        WHEN s.status IN (
            'Accident','Collision','Spun off','Collision damage',
            'Damage','Safety concerns','Fatal accident'
        )                                           THEN 'Incident'
        ELSE                                        'Other'
    END                                             AS categoria
FROM dbo.status s;

-- SCD: nk_estado = Business Key; descricao = Fixed; categoria = Fixed
