require 'nokogiri'
require 'httparty'

class CollectMoreCompanyInfoJob < ApplicationJob
  queue_as :default

  INTERVAL = 2

  def perform
    company = Company.where(coletando_info: false).first
    
    if company
      company.update(coletando_info: true)

      company_name = company.nome_fantasia || company.razao_social

      body = find_in_google("#{company_name} informacoes", true)

      if body.nil?
        return nil
      end

      doc = Nokogiri::HTML(body)

      if company.website.blank?
        website_div = doc.css('div').find do |div|
          div.inner_html && div.inner_html == 'Website'
        end

        if website_div&.parent&.name == 'a' && website_div.parent['href']
          company.update(website: extract_main_url(website_div.parent['href']))
        end
      end

      if company.contato.blank? || company.contato['telefone_maps'].blank?
        phone_div = doc.css('span').find do |span|
          span.inner_html && span.inner_html == 'Telefone'
        end
        phone_number = phone_div&.parent&.next_sibling&.next_sibling&.children&.first&.inner_html
        if phone_number
          company.update(contato: company.contato.merge('telefone_maps' => phone_number)) if phone_div
        end
      end

      if company.linkedin.blank?
        linkedin_search_result = find_in_google("site:linkedin.com #{company_name}", false)
        if linkedin_search_result
          company.update(linkedin: linkedin_search_result)
        end
      end

    end

    self.class.set(wait: INTERVAL.seconds).perform_later
  end

  private

  def extract_main_url(google_search_url)
    uri = URI.parse(google_search_url)
    params = URI.decode_www_form(uri.query).to_h
    main_url = params['q']
    main_url
  end

  def find_in_google(query, return_body = false)
    url = "https://www.google.com/search?q=#{query}"
    
    response = HTTParty.get(url, headers: { "User-Agent" => "Mozilla/5.0" })
  
    if response.code == 200
      if return_body
        return response.body
      end
  
      doc = Nokogiri::HTML(response.body)
      link = nil
  
      link = doc.css('a').find do |a|
        href = a['href']
        href && href.include?('q=') && !href.include?('maps.google.com') && !href.include?('/search') && href.include?('linkedin.com')
      end

      link ? extract_main_url(link['href']) : nil
    end
  end
  
end
