# Extração Base e-DNE Correios SQL Postgres

## Resumo

Este projeto realiza a criação de tabelas em um banco de dados PostgreSQL e extrai os dados dos arquivos `.txt` fornecidos pela base de dados e-DNE dos Correios. O objetivo é estruturar e armazenar informações sobre CEPs, localidades, bairros, estados e países.

## Instruções de Uso

### 1. Execução dos Arquivos

- Execute os scripts SQL na ordem correta, seguindo a estrutura dos diretórios.
- O arquivo principal utilizado é o **Fixo**, que contém os dados essenciais para a criação das tabelas e a extração dos dados.

### 2. Configuração dos Arquivos

- **Atenção:** Na etapa 2, será necessário adicionar o caminho dos arquivos `.txt` na função `pg_read_binary_file` dentro dos scripts SQL.
- Certifique-se de que os caminhos dos arquivos estejam corretos e acessíveis. Exemplo:
  ```sql
  v_arquivo := pg_read_binary_file('/caminho/do/arquivo/DNE_GU_PAISES.TXT');