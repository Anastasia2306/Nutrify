# frozen_string_literal: true

require "yaml"
require "open-uri"

module Nutrify
  class DbManager
    DATA_PATH = File.expand_path("data/additives.yml", __dir__)

    def self.find(code)
      @data ||= YAML.load_file(DATA_PATH)
      @data[code] || { "name" => code, "danger" => "unknown", "description" => "Нет данных" }
    end

    def self.update_database!
      puts "Начинаю обновление базы добавок из сети..."

      url = "https://raw.githubusercontent.com/openfoodfacts/off-server/main/config/taxonomies/additives.txt"

      content = URI.open(url).read

      new_data = {}
      content.each_line do |line|
        next unless line.start_with?("en:e")

        code = line.split("|").first.strip
        new_data[code] = { "name" => code, "danger" => "unknown", "description" => "Автоматически загружено" }
      end

      File.write(DATA_PATH, new_data.to_yaml)
      @data = nil

      puts "База обновлена! Всего добавок: #{new_data.count}"
    end
  end
end
