class ProcessCompaniesJob < ApplicationJob
  queue_as :default

  require "json"
  require "open-uri"
  require "nokogiri"
  require "date"

  def perform
    cnpj_extractor_base_url = "https://casadosdados.com.br/solucao/cnpj?q=a&page"
    cnpj_info_extractor_base_url = "https://api-publica.speedio.com.br/buscarcnpj"
    common_emails = ["gmail", "yahoo", "hotmail", "outlook", "uol", "live", "mail"]

    (1..30).each do |page_number|
      Rails.logger.info "Buscando CNPJs na página #{page_number}..."

      cnpj_extractor_body = Nokogiri::HTML(URI.open("#{cnpj_extractor_base_url}=#{page_number}"))
      companies_extracted_cnpj = cnpj_extractor_body.css(".box")

      companies_extracted_cnpj.each do |company|
        cnpj = company.css("strong").first.text
        clean_cnpj = cnpj.gsub(/\D/, "")

        cnpj_info_res = Net::HTTP.get_response(URI.parse("#{cnpj_info_extractor_base_url}?cnpj=#{clean_cnpj}"))

        if cnpj_info_res.code != "200"
          Rails.logger.error "Erro ao pegar informações de CNPJ #{clean_cnpj}: #{cnpj_info_res.code}"
          next
        end

        cnpj_infos = JSON.parse(cnpj_info_res.body)
        email_domain = cnpj_infos["EMAIL"].split("@")[1]
        website = nil

        if email_domain && !common_emails.include?(email_domain.split(".")[0])
          website = "https://#{email_domain}"
        end

        begin
          company = Company.new({
            nome_fantasia: cnpj_infos["NOME FANTASIA"],
            razao_social: cnpj_infos["RAZAO SOCIAL"],
            data_abertura: Date.parse(cnpj_infos["DATA ABERTURA"]),
            cnpj: cnpj_infos["CNPJ"],
            status: cnpj_infos["STATUS"],
            cnae: {
              descricao: cnpj_infos["CNAE PRINCIPAL DESCRICAO"],
              codigo: Integer(cnpj_infos["CNAE PRINCIPAL CODIGO"])
            },
            endereco: {
              cep: cnpj_infos["CEP"],
              tipo_logradouro: cnpj_infos["TIPO LOGRADOURO"],
              logradouro: cnpj_infos["LOGRADOURO"],
              numero: cnpj_infos["NUMERO"],
              complemento: cnpj_infos["COMPLEMENTO"],
              bairro: cnpj_infos["BAIRRO"],
              municipio: cnpj_infos["MUNICIPIO"],
              uf: cnpj_infos["UF"]
            },
            contato: {
              ddd: cnpj_infos["DDD"],
              telefone: cnpj_infos["TELEFONE"],
              email: cnpj_infos["EMAIL"],
              telefone_maps: nil
            },
            linkedin: nil,
            website: website,
            coletando_info: false
          })

          company.save!
        rescue => e
          Rails.logger.error "Erro ao cadastrar um CNPJ, pulando para o próximo... #{e.message}"
          next
        end
      end

      sleep 2
    end
  end
end
