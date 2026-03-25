# frozen_string_literal: true

require "faraday"
require "faraday/retry"
require "json"
require "fileutils"

module Nutrify
  class Client
    API_URL = "https://world.openfoodfacts.org/api/v2/product/"
    CACHE_DIR = "tmp/nutrify_cache"

    def initialize
      FileUtils.mkdir_p(CACHE_DIR)

      @connection = Faraday.new(url: API_URL) do |f|
        f.request :retry, { max: 3, interval: 0.5 }
        f.options.timeout = 5
        f.adapter Faraday.default_adapter
      end
    end

    def analyze(barcode)
      cached_data = read_from_cache(barcode)
      return Nutrify::Product.new(cached_data) if cached_data

      response = @connection.get("#{barcode}.json")
      return nil unless response.success?

      data = JSON.parse(response.body)
      return nil if data["status"].zero?

      write_to_cache(barcode, data["product"])

      Nutrify::Product.new(data["product"])
    end

    private

    def cache_path(barcode)
      File.join(CACHE_DIR, "#{barcode}.json")
    end

    def read_from_cache(barcode)
      path = cache_path(barcode)
      return nil unless File.exist?(path)

      return nil if Time.now - File.mtime(path) > 86_400

      JSON.parse(File.read(path))
    end

    def write_to_cache(barcode, product_data)
      File.write(cache_path(barcode), JSON.generate(product_data))
    end
  end
end
