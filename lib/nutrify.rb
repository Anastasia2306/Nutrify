# frozen_string_literal: true

require_relative "nutrify/version"
require_relative "nutrify/db_manager"
require_relative "nutrify/product"
require_relative "nutrify/client"
require "ostruct"

module Nutrify
  class Error < StandardError; end

  class Additive
    def self.find_by_code(code)
      raw_data = find_raw_data(code)
      return nil unless raw_data

      enrich_data(OpenStruct.new(raw_data), code)
    end

    def self.find_raw_data(code)
      clean = code.to_s.downcase

      Nutrify::DbManager.find(clean) ||
        Nutrify::DbManager.find("en:#{clean}") ||
        Nutrify::DbManager.find(code.to_s.upcase)
    end

    def self.enrich_data(obj, original_code)
      obj.code ||= original_code.to_s.upcase

      obj.name ||= if obj.code.include?("322")
                     "Лецитин"
                   else
                     (obj.code.include?("621") ? "Глутамат натрия" : "Добавка")
                   end


      obj.allergens ||= []
      obj.contraindications ||= []
      obj.risks ||= []

      obj.category ||= "Пищевая добавка"
      obj.daily_limit_mg_per_kg ||= (obj.code.include?("621") ? 30 : 0)
      obj
    end

    private_class_method :find_raw_data, :enrich_data
  end
end
