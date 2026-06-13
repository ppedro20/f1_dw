-- ============================================================
-- F1_DB - Base de Dados OLTP (Staging)
-- ============================================================
-- Esta base de dados espelha as fontes de dados originais
-- (CSV + JSON) e servira de origem para o F1_DW (OLAP).
-- ============================================================

USE master;
GO

-- Drop se existir (para permitir re-execucao limpa)
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'F1_DB')
BEGIN
    ALTER DATABASE F1_DB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE F1_DB;
END
GO

CREATE DATABASE F1_DB;
GO

USE F1_DB;
GO

PRINT 'Base de dados F1_DB criada com sucesso.';
GO
