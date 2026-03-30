# frozen_string_literal: true

require "httparty"
require "nokogiri"

module NutriAnalyzer
  class Client
    ANALYZER_URL = "https://calorizator.ru/analyzer/addon"

    def self.fetch_analysis(ingredients_text)
      options = {
        body: { "ingredients" => ingredients_text, "op" => "Анализировать" },
        headers: { "Content-Type" => "application/x-www-form-urlencoded" }
      }

      response = HTTParty.post(ANALYZER_URL, options)
      return [] unless response.code == 200

      parse_results(response.body)
    rescue StandardError => e
      puts "Ошибка сети: #{e.message}"
      []
    end

    def self.parse_results(html_body)
      doc = Nokogiri::HTML(html_body)
      found = []

      # Ищем ссылки на добавки
      doc.css("a[href*='/additive/']").each do |link|
        code = link["href"].split("/").last
        found << code.upcase if code
      end

      # Ищем коды в тексте на случай, если ссылок нет
      text_codes = doc.text.scan(/[EeЕе]\s?\d{3,4}/).map do |c|
        c.gsub(/\s/, "").upcase.gsub("Е", "E")
      end

      (found + text_codes).uniq
    end
  end
end
