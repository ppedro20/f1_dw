# 1_fontes — Reengenharia Inversa da BD Operacional

Documentação da base de dados operacional `f1_operacional` (SQL Server).

## Conteúdo

| Ficheiro | Estado | Descrição |
|---|---|---|
| `dicionario_dados.md` | ✅ | Todas as 18 tabelas com colunas, tipos, domínio, PO e chaves |
| `regras_negocio.md` | ✅ | Relações, restrições e notas de cobertura temporal |
| `erd_f1_operacional.png` | ✅ | Diagrama ERD — exportar do SSMS (Database Diagrams) |

## Como exportar o ERD do SSMS

1. Ligar ao servidor no SSMS
2. Expandir `f1_operacional` → `Database Diagrams`
3. Clicar com o botão direito → `New Database Diagram`
4. Adicionar todas as tabelas
5. `File` → `Export as Image` → guardar como `erd_f1_operacional.png` nesta pasta
