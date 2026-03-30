# frozen_string_literal: true

module NutriAnalyzer
  class Product
    attr_reader :name, :additives

    def initialize(arg1, arg2 = nil)
      if arg2.nil?
        @name = "Unknown Product"
        ingredients_text = arg1
      else
        @name = arg1
        ingredients_text = arg2
      end

      ingredients_text = ingredients_text.to_s if ingredients_text.is_a?(Hash)

      @additives = NutriAnalyzer::Parser.parse(ingredients_text || "")
    end
  end
end
