# frozen_string_literal: true

require_relative "client"
require_relative "../nutrify/data"

module NutriAnalyzer
  # Извлекает добавки из текста состава
  class Parser
    E_CODE_REGEX = /[EeЕе][- ]?(\d{3,4})/i

    def self.parse(text)
      text = text.to_s unless text.is_a?(String)
      return [] if text.strip.empty?

      text_dn = text.downcase
      additives = extract_by_e_codes(text_dn) + extract_by_names(text_dn)
      additives += fetch_external_if_needed(additives, text)

      additives.compact.uniq(&:code)
    end

    def self.fetch_external_if_needed(current_additives, text)
      # Проверка: если ничего не нашли и это похоже на одно слово/код
      return [] unless current_additives.empty? && text.length > 2 && !text.include?(" ")

      external_codes = Nutrify::Client.fetch_analysis(text)
      external_codes.map { |code| Additive.find_by_code(code) }
    end

    def self.extract_by_e_codes(text)
      found = []
      text.scan(E_CODE_REGEX) do |match|
        additive = Additive.find_by_code("E#{match[0]}")
        found << additive if additive
      end
      found
    end

    def self.extract_by_names(text)
      Additive.all.select { |additive| text.include?(additive.name.downcase) }
    end

    # Метод для фильтрации
    def self.filter_msg(additives, text)
      additives.reject do |a|
        a.code == "E621" && !text.include?("621") && !text.downcase.include?("глутамат")
      end
    end

    private_class_method :fetch_external_if_needed, :extract_by_e_codes, :extract_by_names
  end
end
