# frozen_string_literal: true

module Nutrify
  class Product
    attr_reader :barcode, :name, :additives

    def initialize(data)
      if data.is_a?(Hash)
        @barcode   = data["code"] || data[:code]
        @name      = data["product_name"] || data[:product_name] || "Неизвестный продукт"
        raw_tags   = data["additives_tags"] || []

        @additives = raw_tags.map do |tag|
          code = tag.split(":").last.upcase
          Nutrify::Additive.find_by_code(code)
        end.compact
      else
        @barcode   = data.to_s
        @name      = "Неизвестный продукт"
        @additives = []
      end
    end
  end
end
