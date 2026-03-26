# frozen_string_literal: true

module NutriAnalyzer
  # Извлекает из текста состава список добавок (E-коды и названия)
  class Parser
    # Синонимы: текстовые варианты названий добавок, которые нужно привести к коду
    SYNONYMS = {
      "глутамат натрия" => "E621",
      "тартразин" => "E102",
      "лецитин" => "E322"
      # ... другие синонимы
    }.freeze

    # Регулярное выражение для поиска E-кодов (Exxx, E xxx, E-xxx)
    E_CODE_REGEX = /\bE[- ]?(\d{3,4})\b/i

    # Основной метод: принимает строку состава и возвращает массив найденных добавок
    def self.parse(ingredients_text)
      return [] if ingredients_text.to_s.empty?

      text = ingredients_text.downcase
      additives = []

      # 1. Ищем E-коды
      text.scan(E_CODE_REGEX) do |match|
        code = "E#{match[0].upcase}"
        additive = Additive.find_by_code(code)
        additives << additive if additive
      end

      # 2. Ищем текстовые названия из синонимов
      SYNONYMS.each do |name, code|
        next unless text.include?(name.downcase)

        additive = Additive.find_by_code(code)
        additives << additive if additive
      end

      # Удаляем дубликаты (по коду)
      additives.uniq(&:code)
    end
  end
end
