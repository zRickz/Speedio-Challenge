require 'elasticsearch'

Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: ENV['ELASTIC_SEARCH_URL'] || 'http://elasticsearch:9200',
  log: false,
  transport_options: {
    headers: { Authorization: "Basic " + Base64.encode64("elastic:speedio").strip }
  }
)
