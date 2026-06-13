# 3_modelo — Modelo Dimensional

Desenho do Data Warehouse `f1_dw`: factos, dimensões, hierarquias e mapeamento das fontes.

## Conteúdo

| Ficheiro | Estado | Descrição |
|---|---|---|
| `modelo_dimensional.md` | ✅ | Definição de factos, dimensões, atributos e hierarquias |
| `matriz_mapeamento.xlsx` | ✅ | Mapeamento fonte OLTP → DW (formato template da UC) |
| `star_schema.png` | ⬜ | Diagrama star schema — criar em draw.io ou ERDPlus |

---

## Como construir o modelo — passo a passo

### 1. Identificar os factos
Pergunta: *o que queremos medir?*  
Cada facto é um evento mensurável com granularidade clara.  
→ Ver `modelo_dimensional.md` — secção Factos.

### 2. Identificar as dimensões
Pergunta: *por que eixos queremos analisar as medidas?*  
Cada dimensão é uma perspetiva de análise (quem, onde, quando, o quê).  
→ Mínimo exigido: 4 dimensões, 2 com hierarquias.

### 3. Definir atributos e hierarquias
Para cada dimensão: listar os atributos descritivos e organizar em hierarquias naturais.  
Ex: `dim_circuito` → Continente → País → Circuito  
→ Ver `modelo_dimensional.md` — secção Dimensões.

### 4. Desenhar o star schema
Usar **draw.io** (gratuito, online) ou **ERDPlus**.  
- Tabela de factos ao centro
- Dimensões à volta, ligadas por chaves surrogate (sk_)
- Guardar como `star_schema.png` nesta pasta

### 5. Preencher a matriz de mapeamento
Abrir `matriz_mapeamento.xlsx`.  
A matriz tem 4 tipos de folhas:
- **Matriz** — visão geral: quais dimensões cada facto usa (marcar com 1)
- **dim_*** — uma folha por dimensão: atributos, origem OLTP, regras de transformação
- **fact_*** — uma folha por facto: medidas, origem OLTP, relacionamentos com dimensões

### 6. Definir as chaves surrogate
Todas as tabelas de dimensão têm uma chave surrogate `sk_` (INT IDENTITY).  
A tabela de factos só tem chaves estrangeiras `sk_` — nunca chaves naturais da fonte.

---

## Convenções

| Prefixo | Significado |
|---|---|
| `dim_` | Tabela de dimensão |
| `fact_` | Tabela de factos |
| `sk_` | Surrogate key — gerada pelo DW (IDENTITY) |
| `nk_` | Natural key — chave original da BD operacional |
