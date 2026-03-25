# frozen_string_literal: true

# lib/nutri_analyzer.rb
require_relative "nutri_analyzer/version"
require_relative "nutri_analyzer/additive"
require_relative "nutri_analyzer/parser"
require_relative "nutri_analyzer/profile"
require_relative "nutri_analyzer/analyzer"
require_relative "nutri_analyzer/report"
require_relative "nutri_analyzer/comparator"

module NutriAnalyzer
  class Error < StandardError; end

  # Удобная точка входа: принимает текст состава и профиль, возвращает отчёт
  def self.analyze_product(product_name, ingredients_text, profile = nil)
    additives = Parser.parse(ingredients_text)
    analyzer = Analyzer.new(additives, profile)
    analysis = analyzer.analyze
    Report.generate(product_name, additives, analysis)
  end

  # Сравнение двух продуктов
  def self.compare_products(ingredients_text_a, ingredients_text_b, profile = nil)
    additives_a = Parser.parse(ingredients_text_a)
    additives_b = Parser.parse(ingredients_text_b)
    Comparator.compare(additives_a, additives_b, profile)
  end
end
