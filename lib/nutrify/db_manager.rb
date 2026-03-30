# frozen_string_literal: true

require "fileutils"
require "yaml"

module Nutrify
  class DbManager
    DATA_PATH = File.join(Dir.pwd, "data", "additives_cache.yml")

    def self.find(code)
      @data ||= load_local_data
      clean_code = code.to_s.upcase

      return @data[clean_code] if @data[clean_code]

      { "name" => clean_code, "danger" => "unknown", "description" => "Нет данных в кэше" }
    end

    def self.update_database!
      puts "Обновляю локальный кэш добавок из сетевого модуля..."

      codes = NutriAnalyzer::Additive.all.map(&:code)

      new_data = {}
      codes.each do |code|
        Nutrify::Client.fetch_analysis(code)
        new_data[code] = {
          "name" => code,
          "danger" => "low",
          "updated_at" => Time.now.to_s
        }
      end

      FileUtils.mkdir_p(File.dirname(DATA_PATH))
      File.write(DATA_PATH, new_data.to_yaml)
      @data = nil
      puts "Кэш обновлен! Записано добавок: #{new_data.count}"
    end

    def self.load_local_data
      return {} unless File.exist?(DATA_PATH)

      YAML.load_file(DATA_PATH) || {}
    rescue StandardError
      {}
    end

    private_class_method :load_local_data
  end
end
