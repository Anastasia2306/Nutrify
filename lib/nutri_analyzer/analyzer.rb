# lib/nutri_analyzer/analyzer.rb
# frozen_string_literal: true


require_relative "additive_evaluator"
require_relative "combination_analyzer"

module NutriAnalyzer
  # Анализирует список добавок с учётом профиля пользователя
  class Analyzer
    attr_reader :additives, :profile

    def initialize(additives, profile = nil)
      @additives = additives
      @profile = profile || Profile.new
    end

    def analyze(result = { safe: [], risky: [], dangerous: [], warnings: [] })
      additives.each do |add|
        evaluation = AdditiveEvaluator.new(add, profile).evaluate
        categorize_additive(result, add, evaluation)
        result[:warnings].concat(evaluation[:warnings]) if evaluation[:warnings]
      end

      result[:warnings].concat(CombinationAnalyzer.check(additives))
      result
    end

    private

    def categorize_additive(result, add, evaluation)
      if evaluation[:dangerous]
        result[:dangerous] << { additive: add, reasons: evaluation[:reasons] }
      elsif evaluation[:risky]
        result[:risky] << { additive: add, reasons: evaluation[:reasons] }
      else
        result[:safe] << add
      end
    end
  end
end
