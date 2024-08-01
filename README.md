# Speedio Challenge - API

## Instruções de Inicialização

1. **Configuração do Ambiente**

   Antes de iniciar a aplicação, configure o arquivo `.env` de acordo com as variáveis de ambiente necessárias.

2. **Inicialização da Aplicação**

   Após a configuração do `.env`, inicie a aplicação utilizando Docker Compose. Execute o seguinte comando no terminal:

   ```bash
   docker-compose up
   ```
   
   Isso iniciará todos os serviços configurados no Docker Compose, incluindo a aplicação e quaisquer serviços auxiliares necessários.

## Rotas Disponíveis
- /buscar
  - **Parâmetro**: query (obrigatório): CNPJ com apenas números ou nome da empresa para realizar a busca.
  - **Método**: GET
  - **Retorno**: Uma lista com os resultados da busca. A lista pode incluir informações sobre o CNPJ ou Nome da empresa, conforme os dados disponíveis.

## Principais Tecnologias Utilizadas
- **Ruby on Rails**: API
- **Rake**: Gerenciamento de rotinas/tasks
- **Nokogiri**: Scrapping de páginas
- **Mongoid**: Conexão, Execução de comandos e mais com MongoDB
- **Elastic Search**: Motor de busca