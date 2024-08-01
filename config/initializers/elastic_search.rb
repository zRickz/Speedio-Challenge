require 'elasticsearch'

sleep 15

Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: ENV['ELASTIC_SEARCH_URL'] || 'http://elasticsearch:9200',
  log: false,
  transport_options: {
    headers: { Authorization: "Basic " + Base64.encode64("elastic:speedio").strip }
  }
)

Rails.application.config.to_prepare do
  Company.__elasticsearch__.create_index!(force: true)
  Company.__elasticsearch__.import(batch_size: 1000)
end