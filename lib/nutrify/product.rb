# frozen_string_literal: true

module Nutrify
  class Product
    attr_reader :barcode, :name, :additives

    def initialize(data)
      @barcode = data["code"]
      @name = data["product_name"] || "Unknown"

      codes = data["additives_tags"] || []

      @additives = codes.map { |code| Nutrify::DbManager.find(code) }
    end
  end
end
