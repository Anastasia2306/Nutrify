# frozen_string_literal: true

require_relative "nutrify/version"
require_relative "nutrify/db_manager"
require_relative "nutrify/product"
require_relative "nutrify/client"

module Nutrify
  class Error < StandardError; end

  # Адаптер для работы с пищевыми добавками
  class Additive
    Data = Struct.new(:code, :name, :allergens, :contraindications, :risks,
                      :category, :daily_limit_mg_per_kg, :danger, :description,
                      :origin, keyword_init: true)

    def self.find_by_code(code)
      raw_data = find_raw_data(code)
      return nil unless raw_data

      data_hash = raw_data.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      obj = Data.new(**data_hash)
      enrich_data(obj, code)
    end

    def self.find_raw_data(code)
      clean = code.to_s.downcase
      Nutrify::DbManager.find(clean) ||
        Nutrify::DbManager.find("en:#{clean}") ||
        Nutrify::DbManager.find(code.to_s.upcase)
    end

    def self.enrich_data(obj, original_code)
      obj.code ||= original_code.to_s.upcase
      obj.origin ||= "vegetable"
      obj.category ||= "Пищевая добавка"

      apply_defaults_by_code(obj)
      fill_arrays(obj)
      obj
    end

    def self.apply_defaults_by_code(obj)
      obj.name = detect_name(obj.code) if obj.name.nil? || obj.name.to_s.downcase == obj.code.to_s.downcase

      obj.danger = obj.code.include?("322") ? "low" : (obj.danger || "unknown")

      obj.daily_limit_mg_per_kg ||= (obj.code.include?("621") ? 30 : 0)
    end

    def self.fill_arrays(obj)
      obj.allergens ||= []
      obj.contraindications ||= []
      obj.risks ||= []
    end

    def self.detect_name(code)
      return "Лецитин" if code.include?("322")
      return "Глутамат натрия" if code.include?("621")

      "Добавка"
    end

    private_class_method :find_raw_data, :enrich_data, :apply_defaults_by_code,
                         :fill_arrays, :detect_name
  end
end
