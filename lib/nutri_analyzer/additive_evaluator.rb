# lib/nutri_analyzer/additive_evaluator.rb
# frozen_string_literal: true

module NutriAnalyzer
  # Оценивает отдельную добавку: опасна, рискованна, безопасна
  class AdditiveEvaluator
    attr_reader :additive, :profile

    def initialize(additive, profile)
      @additive = additive
      @profile = profile
    end

    def evaluate
      {
        dangerous: dangerous?,
        risky: risky?,
        reasons: collect_reasons,
        warnings: collect_warnings
      }
    end

    private

    def dangerous?
      allergic? || !diet_compatible? || contraindicated?
    end

    def risky?
      child_risks? || general_risks?
    end

    def allergic?
      additive.allergens.any? { |a| profile.allergic_to?(a) }
    end

    def diet_compatible?
      profile.diet_compatible?(additive.origin)
    end

    def contraindicated?
      additive.contraindications.any? { |c| profile.contraindication?(c) }
    end

    def child_risks?
      profile.child? && additive.risks.any? { |r| r.include?("дети") }
    end

    def general_risks?
      additive.risks.any?
    end

    def collect_reasons
      reasons = []
      reasons.concat(allergy_reasons) if allergic?
      reasons.concat(diet_reasons) unless diet_compatible?
      reasons.concat(contraindication_reasons) if contraindicated?
      reasons
    end

    def allergy_reasons
      ["Содержит аллерген(ы): #{additive.allergens.join(', ')}"]
    end

    def diet_reasons
      ["Происхождение '#{additive.origin}' не соответствует диете '#{profile.diet}'"]
    end

    def contraindication_reasons
      additive.contraindications.map { |c| "Противопоказано при #{c}" }
    end

    def collect_warnings
      warnings = []
      warnings.concat(child_warnings) if child_risks?
      warnings.concat(daily_limit_warning) if daily_limit_exists?
      warnings.concat(general_risks_warning) if general_risks?
      warnings
    end

    def child_warnings
      ["Данная добавка может быть опасна для детей: #{additive.risks.join(', ')}"]
    end

    def daily_limit_exists?
      additive.daily_limit_mg_per_kg && profile.weight_kg
    end

    def daily_limit_warning
      max_mg = profile.max_safe_daily_mg(additive)
      ["Рекомендуемая суточная норма: #{max_mg} мг (для вашего веса)"] if max_mg
    end

    def general_risks_warning
      ["Потенциальные риски: #{additive.risks.join(', ')}"]
    end
  end
end
