# frozen_string_literal: true

require "faraday"
require "json"

module Nutrify
  class Client
    BASE_URL = "https://world.openfoodfacts.org/api/v0"

    def initialize
      @connection = Faraday.new(url: BASE_URL) do |f|
        f.options.timeout = 5
        f.adapter Faraday.default_adapter
      end
    end

    def analyze(barcode)
      response = @connection.get("product/#{barcode}.json")
      return nil unless response.success?

      data = JSON.parse(response.body)
      return nil if data["status"].zero?

      p_data = data["product"]

      Nutrify::Product.new(
        barcode: barcode,
        name: p_data["product_name"],
        additives: parse_additives(p_data),
        ingredients_text: p_data["ingredients_text"]
      )
    end

    private

    def parse_additives(p_data)
      tags = p_data["additives_tags"] || []
      tags.map { |tag| tag.split(":").last.upcase }
    end
  end
end
