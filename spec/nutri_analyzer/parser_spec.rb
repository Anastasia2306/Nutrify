# frozen_string_literal: true

require "spec_helper"

RSpec.describe NutriAnalyzer::Parser do
  describe ".parse" do
    context "с пустым или nil вводом" do
      it "возвращает пустой массив для nil" do
        expect(described_class.parse(nil)).to eq([])
      end

      it "возвращает пустой массив для пустой строки" do
        expect(described_class.parse("")).to eq([])
      end
    end

    context "с разными раскладками и форматами E-кодов" do
      it "находит английскую E330 и русскую Е330" do
        results_en = described_class.parse("E330")
        results_ru = described_class.parse("Е330") # Русская Е

        expect(results_en.first.code).to eq("E330")
        expect(results_ru.first.code).to eq("E330")
      end

      it "игнорирует регистр (e621)" do
        additives = described_class.parse("e621")
        expect(additives.first.code).to eq("E621")
      end

      it "понимает коды с пробелом (E 211) или дефисом (E-211)" do
        expect(described_class.parse("E 211").first.code).to eq("E211")
        expect(described_class.parse("E-211").first.code).to eq("E211")
      end
    end

    context "интеграция с внешним поиском (Client)" do
      it "вызывает Nutrify::Client для глубокого анализа" do
        # Проверяем, что парсер обращается к сетевому клиенту
        expect(Nutrify::Client).to receive(:fetch_analysis).with("вода").and_return(["E330"])

        results = described_class.parse("вода")
        expect(results.first.code).to eq("E330")
      end
    end

    context "умная фильтрация Глутамата (E621)" do
      it "удаляет E621, если цифр '621' нет в тексте состава" do
        # Имитируем, что API ошибочно нашло глутамат в слове 'вода'
        allow(Nutrify::Client).to receive(:fetch_analysis).and_return(["E621"])

        results = described_class.parse("просто чистая вода")
        expect(results.map(&:code)).not_to include("E621")
      end

      it "оставляет E621, если код явно написан в составе" do
        results = described_class.parse("состав: E621")
        expect(results.map(&:code)).to include("E621")
      end
    end

    context "текстовые названия и синонимы" do
      it "находит добавку по названию 'Тартразин'" do
        # Исправлено: добавлены кавычки и скобка
        results = described_class.parse("краситель Тартразин")
        expect(results.first.code).to eq("E102")
      end

      it "не создает дубликаты, если код и название написаны вместе" do
        results = described_class.parse("E102 (Тартразин)")
        expect(results.size).to eq(1)
      end
    end
  end
end
