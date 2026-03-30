# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NutriAnalyzer Integration Tests" do
  let(:profile) do
    NutriAnalyzer::Profile.new(
      allergies: ["соя"],
      diet: "vegan",
      age: 30,
      chronic_diseases: [],
      weight_kg: 70
    )
  end

  describe "Полный цикл анализа продукта" do
    it "анализирует продукт с E-кодами и текстовыми названиями" do
      ingredients = "вода, E621, Е322, тартразин"
      report = NutriAnalyzer.analyze_product("Чипсы", ingredients, profile)

      expect(report).to include("Чипсы")
      expect(report).to include("Лецитин")
      expect(report).to include("Глутамат натрия")
    end

    it "учитывает противопоказания пользователя" do
      profile_with_asthma = NutriAnalyzer::Profile.new(chronic_diseases: ["астма"])
      ingredients = "E102"
      report = NutriAnalyzer.analyze_product("Тест", ingredients, profile_with_asthma)

      expect(report).to include("Опасные добавки")
      expect(report).to include("Противопоказано при астма")
    end
  end

  describe "Работа с API Calorizator (моки)" do
    it "интегрируется с внешним модулем через Nutrify" do
      product = NutriAnalyzer::Product.new("Test Product", "E322")

      expect(product).to be_a(NutriAnalyzer::Product)
      expect(product.name).to eq("Test Product")
      expect(product.additives.first.code).to eq("E322")
    end
  end
end
