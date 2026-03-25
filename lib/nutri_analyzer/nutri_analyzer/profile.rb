# frozen_string_literal: true

# lib/nutri_analyzer/profile.rb
module NutriAnalyzer
  # Профиль пользователя с индивидуальными ограничениями
  class Profile
    attr_reader :allergies, :diet, :age, :chronic_diseases, :weight_kg

    # Параметры:
    #   allergies: Array<String> – список аллергенов (например, ["лактоза", "глютен"])
    #   diet: String – тип диеты: "vegan", "vegetarian", "gluten_free", "none"
    #   age: Integer – возраст (для оценки рисков у детей)
    #   chronic_diseases: Array<String> – хронические заболевания
    #   weight_kg: Float – вес (для расчёта суточной нормы)
    def initialize(allergies: [], diet: "none", age: nil, chronic_diseases: [], weight_kg: nil)
      @allergies = allergies.map(&:downcase).uniq
      @diet = diet.downcase
      @age = age
      @chronic_diseases = chronic_diseases.map(&:downcase)
      @weight_kg = weight_kg
    end

    # Проверяет, есть ли у пользователя аллергия на указанный аллерген
    def allergic_to?(allergen)
      allergies.include?(allergen.downcase)
    end

    # Проверяет, соответствует ли происхождение добавки диете
    def diet_compatible?(origin)
      return true if diet == "none"
      return false if diet == "vegan" && animal_origin?(origin)
      return false if diet == "vegetarian" && origin == "животное"

      true
    end

    # Проверяет, есть ли у пользователя противопоказание
    def contraindication?(contraindication)
      chronic_diseases.any? { |d| contraindication.downcase.include?(d) }
    end

    # Определяет, относится ли пользователь к группе риска для детей
    def child?
      age && age < 12
    end

    # Рассчитывает максимальную безопасную дозу (мг) для добавки на основе веса
    def max_safe_daily_mg(additive)
      return nil unless weight_kg && additive.daily_limit_mg_per_kg

      weight_kg * additive.daily_limit_mg_per_kg
    end

    private

    def animal_origin?(origin)
      %w[животное молочное].include?(origin)
    end
  end
end
