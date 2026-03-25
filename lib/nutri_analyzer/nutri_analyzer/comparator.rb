# frozen_string_literal: true

# lib/nutri_analyzer/comparator.rb
module NutriAnalyzer
  # Сравнивает два продукта и определяет, какой безопаснее
  class Comparator
    # Принимает два массива добавок и профиль пользователя
    def self.compare(additives_a, additives_b, profile = nil)
      profile ||= Profile.new

      result_a = Analyzer.new(additives_a, profile).analyze
      result_b = Analyzer.new(additives_b, profile).analyze

      build_result(result_a, result_b)
    end

    def self.build_result(result_a, result_b)
      score_a = calculate_score(result_a)
      score_b = calculate_score(result_b)
      better = determine_better(score_a, score_b)

      {
        product_a: { score: score_a, dangerous: result_a[:dangerous].size, risky: result_a[:risky].size },
        product_b: { score: score_b, dangerous: result_b[:dangerous].size, risky: result_b[:risky].size },
        better: better
      }
    end
    private_class_method :build_result

    def self.calculate_score(result)
      (result[:dangerous].size * 10) + (result[:risky].size * 2)
    end
    private_class_method :calculate_score

    def self.determine_better(score_a, score_b)
      if score_a < score_b
        :product_a
      elsif score_b < score_a
        :product_b
      else
        :equal
      end
    end
    private_class_method :determine_better
  end
end
