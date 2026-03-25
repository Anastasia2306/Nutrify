# frozen_string_literal: true

require_relative "nutrify/version"
require_relative "nutrify/db_manager"
require_relative "nutrify/product"
require_relative "nutrify/client"

module Nutrify
  class Error < StandardError; end

  class Additive
    def self.find_by_code(code)
      data = Nutrify::DbManager.find(code)
      return nil unless data

      require "ostruct"
      OpenStruct.new(data)
    end
  end
end
