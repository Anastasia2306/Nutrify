# frozen_string_literal: true

# lib/nutri_analyzer/additive.rb
module NutriAnalyzer
  # Класс, предоставляющий информацию о пищевой добавке.
  class Additive
    # Пример данных (в реальности загружается из API)
    DATA = {
      "E621" => {
        name: "Глутамат натрия",
        category: "усилитель вкуса",
        origin: "синтетическое",
        risks: ["аллергия", "головная боль"],
        contraindications: ["беременность", "дети до 3 лет"],
        daily_limit_mg_per_kg: 30,
        allergens: []
      },
      "E102" => {
        name: "Тартразин",
        category: "краситель",
        origin: "синтетическое",
        risks: ["аллергия", "гиперактивность у детей"],
        contraindications: ["астма", "непереносимость аспирина"],
        daily_limit_mg_per_kg: 7.5,
        allergens: []
      },
      "E322" => {
        name: "Лецитин",
        category: "эмульгатор",
        origin: "растительное",
        risks: [],
        contraindications: [],
        daily_limit_mg_per_kg: nil,
        allergens: ["соя"]
      }
    }.freeze

    attr_reader :code, :name, :category, :origin, :risks,
                :contraindications, :daily_limit_mg_per_kg, :allergens

    def initialize(code, data)
      @code = code
      @name = data[:name]
      @category = data[:category]
      @origin = data[:origin]
      @risks = data[:risks]
      @contraindications = data[:contraindications]
      @daily_limit_mg_per_kg = data[:daily_limit_mg_per_kg]
      @allergens = data[:allergens]
    end

    # Поиск по E-коду
    def self.find_by_code(code)
      code = code.upcase
      return nil unless DATA.key?(code)

      new(code, DATA[code])
    end

    # Поиск по названию (упрощённо)
    def self.find_by_name(name)
      DATA.each do |code, data|
        return new(code, data) if data[:name].casecmp?(name)
      end
      nil
    end

    def self.all
      DATA.map { |code, data| new(code, data) }
    end
  end
end
