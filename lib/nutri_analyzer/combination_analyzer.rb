# lib/nutri_analyzer/combination_analyzer.rb
# frozen_string_literal: true

module NutriAnalyzer
  # Проверяет наличие опасных комбинаций добавок
  class CombinationAnalyzer
    DANGEROUS_COMBINATIONS = [
      {
        codes: %w[E210 E300],
        message: "Комбинация бензойной кислоты (E210) и аскорбиновой кислоты (E300) " \
                 "может образовывать бензол – канцерогенное вещество."
      },
      {
        codes: %w[E250 E300],
        message: "Нитрит натрия (E250) в сочетании с аскорбиновой кислотой (E300) " \
                 "при нагревании может усиливать образование нитрозаминов (канцерогенов)."
      },
      {
        codes: %w[E250 E621],
        message: "Нитрит натрия (E250) и глутамат натрия (E621) могут вызывать головные боли " \
                 "у чувствительных людей («синдром китайского ресторана»)."
      }
    ].freeze

    def self.check(additives)
      new(additives).check
    end

    def initialize(additives)
      @additives = additives
    end

    def check
      codes = @additives.map(&:code)
      DANGEROUS_COMBINATIONS.each_with_object([]) do |combo, warnings|
        warnings << combo[:message] if combo[:codes].all? { |code| codes.include?(code) }
      end
    end
  end
end
