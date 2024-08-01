class Company
  include Mongoid::Document
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  field :nome_fantasia, type: String
  field :razao_social, type: String
  field :data_abertura, type: Date
  field :cnpj, type: String
  field :status, type: String
  field :cnae, type: Hash
  field :endereco, type: Hash
  field :contato, type: Hash
  field :website, type: String

  index_name [Rails.env, "companies"].join('_')

  settings do
    mappings dynamic: false do
      indexes :nome_fantasia, type: :text
      indexes :razao_social, type: :text
      indexes :data_abertura, type: :date
      indexes :cnpj, type: :keyword
      indexes :status, type: :text
      indexes :cnae, type: :object
      indexes :endereco, type: :object
      indexes :contato, type: :object
      indexes :website, type: :text
    end
  end

  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: {
            query: query,
            fields: ["*"]
          }
        }
      }
    )
  end
end
