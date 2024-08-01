class CompaniesController < ApplicationController
  def search
    query = params[:query]
    if query.present?
      companies = Company.search(query).results

      if companies
        companies = companies.map do |result|
          result._source
        end
      end

      render json: companies
    else
      render json: { error: 'Parâmetro "query" não encontrado.'}, status: :bad_request
    end
  end
end
