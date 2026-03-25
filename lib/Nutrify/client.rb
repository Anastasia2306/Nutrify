# frozen_string_literal: true

require 'faraday'
require 'json'

module Nutrify
  class Client
    BASE_URL = 'https://world.openfoodfacts.org/api/v0'

    def fetch_product(barcode)
      response = Faraday.get("#{BASE_URL}/product/#{barcode}.json")
      return { error: "Ошибка сети" } unless response.success?

      data = JSON.parse(response.body)
      return { error: "Продукт не найден" } if data['status'] == 0

      {
        name: data.dig('product', 'product_name'),
        additives_tags: data.dig('product', 'additives_tags') || []
      }
    end

    def analyze(barcode)
      product = fetch_product(barcode)
      return product if product[:error]

      found_codes = product[:additives_tags].map { |tag| tag.split(':').last.upcase }

      details = found_codes.map do |code|

        info = Nutrify::ADDITIVES[code] || { name: "Неизвестная добавка" }
        { code: code }.merge(info)
      end

      {
        product_name: product[:name],
        analysis: details
      }
    end
  end
end