# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/nutrify/db_manager"

RSpec.describe Nutrify::DbManager do
  before do
    allow(Nutrify::DbManager).to receive(:load_local_data).and_return({
                                                                        "E322" => { "name" => "Лецитин", "danger" => "low", "description" => "Эмульгатор" }
                                                                      })
  end

  describe ".find" do
    it "находит существующую добавку по коду без префиксов" do
      info = Nutrify::DbManager.find("E322")

      expect(info["name"]).to eq("Лецитин")
      expect(info["danger"]).to eq("low")
    end

    it "автоматически приводит код к верхнему регистру" do
      info = Nutrify::DbManager.find("e322")
      expect(info["name"]).to eq("Лецитин")
    end

    it "возвращает структуру с 'Нет данных', если кода нет в кэше" do
      info = Nutrify::DbManager.find("UNKNOWN")

      expect(info["name"]).to eq("UNKNOWN")
      expect(info["description"]).to eq("Нет данных в кэше")
    end
  end

  describe ".update_database!" do
    it "вызывает сетевой клиент для получения данных" do
      expect(Nutrify::Client).to receive(:fetch_analysis).at_least(:once).and_return([])

      Nutrify::DbManager.update_database!
    end
  end
end
