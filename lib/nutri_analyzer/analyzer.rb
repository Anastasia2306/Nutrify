# frozen_string_literal: true

# lib/nutri_analyzer/analyzer.rb
module NutriAnalyzer
  # Анализирует список добавок с учётом профиля пользователя
  class Analyzer
    attr_reader :additives, :profile

    def initialize(additives, profile = nil)
      @additives = additives
      @profile = profile || Profile.new
    end

    # Основная оценка: возвращает хеш с результатами анализа
    def analyze(result = { safe: [], risky: [], dangerous: [], warnings: [] })
      additives.each do |add|
        evaluation = evaluate_additive(add)
        categorize_additive(result, add, evaluation)
        result[:warnings].concat(evaluation[:warnings]) if evaluation[:warnings]
      end
      result
    end

    private

    def evaluate_additive(add)
      {
        dangerous: dangerous?(add),
        risky: risky?(add),
        reasons: collect_reasons(add),
        warnings: collect_warnings(add)
      }
    end

    def categorize_additive(result, add, evaluation)
      if evaluation[:dangerous]
        result[:dangerous] << { additive: add, reasons: evaluation[:reasons] }
      elsif evaluation[:risky]
        result[:risky] << { additive: add, reasons: evaluation[:reasons] }
      else
        result[:safe] << add
      end
    end

    def dangerous?(add)
      return true if allergic?(add)
      return true unless diet_compatible?(add)
      return true if contraindicated?(add)

      false
    end

    def risky?(add)
      return true if child_risks?(add)
      return true if general_risks?(add)

      false
    end

    def allergic?(add)
      add.allergens.any? { |a| profile.allergic_to?(a) }
    end

    def diet_compatible?(add)
      profile.diet_compatible?(add.origin)
    end

    def contraindicated?(add)
      add.contraindications.any? do |c|
        profile.contraindication?(c) # Исправлено: было has_contraindication?, теперь contraindication?
      end
    end

    def child_risks?(add)
      profile.child? && add.risks.any? { |r| r.include?("дети") }
    end

    def general_risks?(add)
      add.risks.any?
    end

    def collect_reasons(add)
      reasons = []
      reasons.concat(allergy_reasons(add)) if allergic?(add)
      reasons.concat(diet_reasons(add)) unless diet_compatible?(add)
      reasons.concat(contraindication_reasons(add)) if contraindicated?(add)
      reasons
    end

    def allergy_reasons(add)
      ["Содержит аллерген(ы): #{add.allergens.join(', ')}"]
    end

    def diet_reasons(add)
      ["Происхождение '#{add.origin}' не соответствует диете '#{profile.diet}'"]
    end

    def contraindication_reasons(add)
      add.contraindications.map { |c| "Противопоказано при #{c}" }
    end

    def collect_warnings(add)
      warnings = []
      warnings.concat(child_warnings(add)) if child_risks?(add)
      warnings.concat(daily_limit_warning(add)) if daily_limit_exists?(add)
      warnings.concat(general_risks_warning(add)) if general_risks?(add)
      warnings
    end

    def child_warnings(add)
      ["Данная добавка может быть опасна для детей: #{add.risks.join(', ')}"]
    end

    def daily_limit_exists?(add)
      add.daily_limit_mg_per_kg && profile.weight_kg
    end

    def daily_limit_warning(add)
      max_mg = profile.max_safe_daily_mg(add)
      ["Рекомендуемая суточная норма: #{max_mg} мг (для вашего веса)"] if max_mg
    end

    def general_risks_warning(add)
      ["Потенциальные риски: #{add.risks.join(', ')}"]
    end
  end
end
