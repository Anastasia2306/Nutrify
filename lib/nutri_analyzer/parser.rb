# lib/nutri_analyzer/parser.rb
# frozen_string_literal: true

module NutriAnalyzer
  # Извлекает из текста состава список добавок (E-коды и названия)
  class Parser
    SYNONYMS = {
      "глутамат натрия" => "E621",
      "тартразин" => "E102",
      "лецитин" => "E322",
      "бензойная кислота" => "E210",
      "аскорбиновая кислота" => "E300",
      "нитрит натрия" => "E250",
      "аспартам" => "E951"
    }.freeze

    E_CODE_REGEX = /\bE[- ]?(\d{3,4})\b/i

    def self.parse(ingredients_text)
      return [] if ingredients_text.to_s.empty?

      text = ingredients_text.downcase
      additives = []

      additives.concat(extract_by_e_codes(text))
      additives.concat(extract_by_synonyms(text))
      additives.concat(extract_by_names(text))

      additives.uniq(&:code)
    end

    private_class_method def self.extract_by_e_codes(text)
      additives = []
      text.scan(E_CODE_REGEX) do |match|
        code = "E#{match[0].upcase}"
        additive = Additive.find_by_code(code)
        additives << additive if additive
      end
      additives
    end

    private_class_method def self.extract_by_synonyms(text)
      additives = []
      SYNONYMS.each do |name, code|
        next unless text.include?(name.downcase)

        additive = Additive.find_by_code(code)
        additives << additive if additive
      end
      additives
    end

    private_class_method def self.extract_by_names(text)
      additives = []
      Additive.all.each do |additive|
        next if additives.any? { |a| a.code == additive.code }

        additives << additive if text.include?(additive.name.downcase)
      end
      additives
    end
  end
end
