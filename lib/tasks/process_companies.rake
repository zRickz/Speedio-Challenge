namespace :process do
  desc "Processar informações das empresas"
  task companies: :environment do
    require "json"
    require "open-uri"
    require "nokogiri"
    require "date"

    cnpjExtractorBaseUrl = "https://casadosdados.com.br/solucao/cnpj?q=a&page"
    cnpjInfoExtractorBaseUrl = "https://api-publica.speedio.com.br/buscarcnpj"
    commonEmails = ["gmail", "yahoo", "hotmail", "outlook", "uol", "live", "mail"]

    (1..25).each do |page_number|
      puts "Buscando CNPJs na página #{page_number}..."

      cnpjExtractorBody = Nokogiri::HTML(URI.open("#{cnpjExtractorBaseUrl}=#{page_number}"))
      companiesExtractedCnpj = cnpjExtractorBody.css(".box")

      companiesExtractedCnpj.each do |company|
        cnpj = company.css("strong").first.text
        cleanCnpj = cnpj.gsub(/\D/, "")

        cnpjInfoRes = Net::HTTP.get_response(URI.parse("#{cnpjInfoExtractorBaseUrl}?cnpj=#{cleanCnpj}"))

        if cnpjInfoRes.code != "200"
          puts "Erro ao pegar informações de CNPJ #{cleanCnpj}: #{cnpjInfoRes.code}"
          next
        end

        cnpjInfos = JSON.parse(cnpjInfoRes.body)
        emailDomain = cnpjInfos["EMAIL"].split("@")[1]
        website = nil

        if emailDomain && !commonEmails.include?(emailDomain.split(".")[0])
          website = "https://#{emailDomain}"
        end

        begin
          Company.create({
            nome_fantasia: cnpjInfos["NOME FANTASIA"],
            razao_social: cnpjInfos["RAZAO SOCIAL"],
            data_abertura: Date.parse(cnpjInfos["DATA ABERTURA"]),
            cnpj: cnpjInfos["CNPJ"],
            status: cnpjInfos["STATUS"],
            cnae: {
              descricao: cnpjInfos["CNAE PRINCIPAL DESCRICAO"],
              codigo: Integer(cnpjInfos["CNAE PRINCIPAL CODIGO"])
            },
            endereco: {
              cep: cnpjInfos["CEP"],
              tipo_logradouro: cnpjInfos["TIPO LOGRADOURO"],
              logradouro: cnpjInfos["LOGRADOURO"],
              numero: cnpjInfos["NUMERO"],
              complemento: cnpjInfos["COMPLEMENTO"],
              bairro: cnpjInfos["BAIRRO"],
              municipio: cnpjInfos["MUNICIPIO"],
              uf: cnpjInfos["UF"]
            },
            contato: {
              ddd: cnpjInfos["DDD"],
              telefone: cnpjInfos["TELEFONE"],
              email: cnpjInfos["EMAIL"]
            },
            website: website
          })
        rescue => e
          puts "Erro ao cadastrar um CNPJ, pulando para o próximo..."
          next
        end
      end

      sleep 1
    end
  end
end
