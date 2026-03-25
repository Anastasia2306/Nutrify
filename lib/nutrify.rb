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
      clean_code = code.to_s.downcase
      data = Nutrify::DbManager.find(clean_code) || Nutrify::DbManager.find("en:#{clean_code}")

      return nil unless data

      obj = OpenStruct.new(data)

      obj.code ||= code.to_s.upcase
      obj.allergens ||= []
      obj.category ||= "Пищевая добавка"

      obj.daily_limit_mg_per_kg ||= if obj.code.include?("621")
                                      30
                                    else
                                      0
                                    end

      obj
    end
  end
end
