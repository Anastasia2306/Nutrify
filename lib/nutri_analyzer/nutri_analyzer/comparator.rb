# lib/nutri_analyzer/comparator.rb
module NutriAnalyzer
  # Сравнивает два продукта и определяет, какой безопаснее
  class Comparator
    # Принимает два массива добавок и профиль пользователя
    def self.compare(additives_a, additives_b, profile = nil)
      profile ||= Profile.new

      analyzer_a = Analyzer.new(additives_a, profile)
      analyzer_b = Analyzer.new(additives_b, profile)

      result_a = analyzer_a.analyze
      result_b = analyzer_b.analyze

      score_a = result_a[:dangerous].size * 10 + result_a[:risky].size * 2
      score_b = result_b[:dangerous].size * 10 + result_b[:risky].size * 2

      if score_a < score_b
        better = :product_a
      elsif score_b < score_a
        better = :product_b
      else
        better = :equal
      end

      {
        product_a: { score: score_a, dangerous: result_a[:dangerous].size, risky: result_a[:risky].size },
        product_b: { score: score_b, dangerous: result_b[:dangerous].size, risky: result_b[:risky].size },
        better: better
      }
    end
  end
end