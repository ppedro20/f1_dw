-- ============================================================
-- F1_DW - Indices e Chaves Estrangeiras
-- ============================================================
-- Indices para otimizar consultas analiticas no Data Warehouse
-- e chaves estrangeiras para integridade referencial.
-- ============================================================

USE F1_DW;
GO

-- ============================================================
-- CHAVES ESTRANGEIRAS - Fact_Performance
-- ============================================================

ALTER TABLE Fact_Performance ADD CONSTRAINT FK_FactPerf_DimTempo
    FOREIGN KEY (Data_SK) REFERENCES Dim_Tempo(Data_SK);
GO

ALTER TABLE Fact_Performance ADD CONSTRAINT FK_FactPerf_DimPiloto
    FOREIGN KEY (Piloto_SK) REFERENCES Dim_Piloto(Piloto_SK);
GO

ALTER TABLE Fact_Performance ADD CONSTRAINT FK_FactPerf_DimCircuito
    FOREIGN KEY (Circuito_SK) REFERENCES Dim_Circuito(Circuito_SK);
GO

ALTER TABLE Fact_Performance ADD CONSTRAINT FK_FactPerf_DimConstrutor
    FOREIGN KEY (Construtor_SK) REFERENCES Dim_Construtor(Construtor_SK);
GO

-- ============================================================
-- CHAVES ESTRANGEIRAS - Fact_Volta
-- ============================================================

ALTER TABLE Fact_Volta ADD CONSTRAINT FK_FactVolta_DimTempo
    FOREIGN KEY (Data_SK) REFERENCES Dim_Tempo(Data_SK);
GO

ALTER TABLE Fact_Volta ADD CONSTRAINT FK_FactVolta_DimPiloto
    FOREIGN KEY (Piloto_SK) REFERENCES Dim_Piloto(Piloto_SK);
GO

ALTER TABLE Fact_Volta ADD CONSTRAINT FK_FactVolta_DimCircuito
    FOREIGN KEY (Circuito_SK) REFERENCES Dim_Circuito(Circuito_SK);
GO

ALTER TABLE Fact_Volta ADD CONSTRAINT FK_FactVolta_DimConstrutor
    FOREIGN KEY (Construtor_SK) REFERENCES Dim_Construtor(Construtor_SK);
GO

ALTER TABLE Fact_Volta ADD CONSTRAINT FK_FactVolta_DimComposto
    FOREIGN KEY (Composto_SK) REFERENCES Dim_Composto(Composto_SK);
GO

-- ============================================================
-- INDICES - Fact_Performance
-- ============================================================

-- Clustered columnstore index para fact table (analytical workloads)
CREATE CLUSTERED COLUMNSTORE INDEX CCI_Fact_Performance ON Fact_Performance;
GO

-- Indices non-clustered para joins mais frequentes por dimensao
CREATE INDEX IX_FactPerf_Data_SK         ON Fact_Performance(Data_SK);
CREATE INDEX IX_FactPerf_Piloto_SK       ON Fact_Performance(Piloto_SK);
CREATE INDEX IX_FactPerf_Circuito_SK     ON Fact_Performance(Circuito_SK);
CREATE INDEX IX_FactPerf_Construtor_SK   ON Fact_Performance(Construtor_SK);
GO

-- Indice composto para consultas tipicas por ano + construtor
CREATE INDEX IX_FactPerf_Data_Construtor ON Fact_Performance(Data_SK, Construtor_SK)
    INCLUDE (Pontos_Conquistados, Posicao_Final);
GO

-- ============================================================
-- INDICES - Fact_Volta
-- ============================================================

CREATE CLUSTERED COLUMNSTORE INDEX CCI_Fact_Volta ON Fact_Volta;
GO

CREATE INDEX IX_FactVolta_Data_SK         ON Fact_Volta(Data_SK);
CREATE INDEX IX_FactVolta_Piloto_SK       ON Fact_Volta(Piloto_SK);
CREATE INDEX IX_FactVolta_Circuito_SK     ON Fact_Volta(Circuito_SK);
CREATE INDEX IX_FactVolta_Construtor_SK   ON Fact_Volta(Construtor_SK);
CREATE INDEX IX_FactVolta_Composto_SK     ON Fact_Volta(Composto_SK);
GO

-- Indice composto para consultas por corrida + piloto + volta
CREATE INDEX IX_FactVolta_Data_Piloto_Volta
    ON Fact_Volta(Data_SK, Piloto_SK, Num_Volta)
    INCLUDE (Tempo_Volta_ms, Posicao_na_Volta, Volta_Sob_SC);
GO

-- ============================================================
-- INDICES - Dimensoes
-- ============================================================

-- Dim_Piloto: lookup por nome + filtro de data (SCD2)
CREATE INDEX IX_DimPiloto_NomeCompleto ON Dim_Piloto(Nome_Completo)
    INCLUDE (Piloto_SK, Equipa, Data_Inicio, Data_Fim);
GO

-- Dim_Tempo: lookup por componentes de data
CREATE INDEX IX_DimTempo_Ano_Mes ON Dim_Tempo(Ano, Mes)
    INCLUDE (Data_SK);
GO

-- Dim_Circuito: lookup por nome
CREATE INDEX IX_DimCircuito_Nome ON Dim_Circuito(Nome_Circuito)
    INCLUDE (Circuito_SK, Pais, Continente);
GO

-- Dim_Construtor: lookup por nome
CREATE INDEX IX_DimConstrutor_Nome ON Dim_Construtor(Nome)
    INCLUDE (Construtor_SK, Motorizador);
GO

PRINT 'Indices e chaves estrangeiras do F1_DW criados com sucesso.';
GO
