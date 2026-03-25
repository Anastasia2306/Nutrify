# lib/nutri_analyzer/profile.rb
module NutriAnalyzer
  # Профиль пользователя с индивидуальными ограничениями
  class Profile
    attr_reader :allergies, :diet, :age, :chronic_diseases, :weight_kg

    # Параметры:
    def initialize(allergies: [], diet: "none", age: nil, chronic_diseases: [], weight_kg: nil)
      @allergies = allergies.map(&:downcase) # Array<String> – список аллергенов (например, ["лактоза", "глютен"])
      @diet = diet.downcase # String – тип диеты: "vegan", "vegetarian", "gluten_free", "none"
      @age = age # Integer – возраст
      @chronic_diseases = chronic_diseases.map(&:downcase) # Array<String> – хронические заболевания
      @weight_kg = weight_kg # Float – вес (для расчёта суточной нормы)
    end

    # Проверяет, есть ли у пользователя аллергия на указанный аллерген
    def allergic_to?(allergen)
      allergies.include?(allergen.downcase)
    end

    # Проверяет, соответствует ли происхождение добавки диете
    def diet_compatible?(origin)
      case diet
      when "vegan"
        origin != "животное"
      when "vegetarian"
        origin != "животное" || origin == "молочное" # упрощённо
      when "gluten_free"
        true # gluten проверяется отдельно по аллергенам
      else
        true
      end
    end

    # Проверяет, есть ли у пользователя противопоказание
    def has_contraindication?(contraindication)
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
  end
end