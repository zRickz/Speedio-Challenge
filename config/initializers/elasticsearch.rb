require 'elasticsearch'

sleep 15

Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: ENV['ELASTIC_SEARCH_URL'] || 'http://elasticsearch:9200',
  log: false
)