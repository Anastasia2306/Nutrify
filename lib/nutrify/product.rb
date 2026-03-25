# frozen_string_literal: true

module Nutrify
  class Product
    attr_reader :barcode, :name, :additives, :ingredients_text

    def initialize(barcode:, name:, additives: [], ingredients_text: "")
      @barcode = barcode
      @name = name || "Неизвестный продукт"
      @additives = additives
      @ingredients_text = ingredients_text
    end
  end
end
