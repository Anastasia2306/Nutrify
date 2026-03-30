# frozen_string_literal: true

require_relative "nutri_analyzer"

module Nutrify
  class Error < StandardError; end

  Client = NutriAnalyzer::Client
  Product = NutriAnalyzer::Product

  class Additive
    def self.find_by_code(code)
      NutriAnalyzer::Additive.find_by_code(code)
    end
  end
end
