# frozen_string_literal: true

require "spec_helper"

RSpec.describe "NutriAnalyzer Integration Tests" do
  describe "Полный цикл анализа продукта" do
    let(:profile) do
      NutriAnalyzer::Profile.new(
        allergies: ["соя"],
        diet: "vegan",
        age: 30,
        chronic_diseases: [],
        weight_kg: 70
      )
    end

    it "анализирует продукт с E-кодами и текстовыми названиями" do
      ingredients = "Состав: вода, E621 (глутамат натрия), лецитин (Е322), тартразин E102"
      report = NutriAnalyzer.analyze_product("Чипсы со вкусом сыра", ingredients, profile)

      expect(report).to include("Чипсы со вкусом сыра")
      expect(report).to include("Добавки с потенциальными рисками")
      expect(report).to include("Опасные добавки")
      expect(report).to include("Общие предупреждения")
      expect(report).to include("Лецитин")
      expect(report).to include("Глутамат натрия")
      expect(report).to include("Тартразин")
    end

    it "корректно обрабатывает продукт без добавок" do
      ingredients = "вода, сахар, соль"
      report = NutriAnalyzer.analyze_product("Минеральная вода", ingredients, profile)

      expect(report).to include("Минеральная вода")
      expect(report).not_to include("Добавки с потенциальными рисками")
      expect(report).not_to include("Опасные добавки")
    end

    it "учитывает аллергии в профиле пользователя" do
      profile_with_allergy = NutriAnalyzer::Profile.new(allergies: ["соя"])
      ingredients = "лецитин (Е322), вода"
      report = NutriAnalyzer.analyze_product("Продукт с соей", ingredients, profile_with_allergy)

      expect(report).to include("Опасные добавки")
      expect(report).to include("Лецитин")
      expect(report).to include("Содержит аллерген(ы): соя")
    end

    it "учитывает диету пользователя" do
      vegan_profile = NutriAnalyzer::Profile.new(diet: "vegan")
      ingredients = "E322"
      report = NutriAnalyzer.analyze_product("Веганский продукт", ingredients, vegan_profile)

      expect(report).not_to include("не соответствует диете")
    end

    it "учитывает противопоказания пользователя" do
      profile_with_asthma = NutriAnalyzer::Profile.new(chronic_diseases: ["астма"])
      ingredients = "тартразин E102"
      report = NutriAnalyzer.analyze_product("Продукт с красителем", ingredients, profile_with_asthma)

      expect(report).to include("Опасные добавки")
      expect(report).to include("Тартразин")
      expect(report).to include("Противопоказано при астма")
    end

    it "учитывает возраст пользователя для рисков" do
      child_profile = NutriAnalyzer::Profile.new(age: 8)
      ingredients = "тартразин E102"
      report = NutriAnalyzer.analyze_product("Продукт для детей", ingredients, child_profile)

      expect(report).to include("Добавки с потенциальными рисками")
      expect(report).to include("Тартразин")
      expect(report).to include("Потенциальные риски: аллергия, гиперактивность у детей")
    end
  end

  describe "Сравнение продуктов" do
    let(:profile) { NutriAnalyzer::Profile.new(allergies: ["соя"], weight_kg: 70) }

    it "сравнивает два продукта и выбирает более безопасный" do
      product_a = "лецитин (Е322), вода"
      product_b = "E621, вода"
      result = NutriAnalyzer.compare_products(product_a, product_b, profile)

      expect(result[:better]).to eq(:product_b)
      expect(result[:product_a][:dangerous]).to eq(1)
      expect(result[:product_b][:dangerous]).to eq(0)
      expect(result[:product_a][:risky]).to eq(0)
      expect(result[:product_b][:risky]).to eq(1)
    end

    it "сравнивает идентичные продукты" do
      product = "E621, E102, вода"
      result = NutriAnalyzer.compare_products(product, product, profile)

      expect(result[:better]).to eq(:equal)
      expect(result[:product_a][:score]).to eq(result[:product_b][:score])
    end

    it "сравнивает продукты без добавок" do
      result = NutriAnalyzer.compare_products("вода", "вода", profile)

      expect(result[:better]).to eq(:equal)
      expect(result[:product_a][:score]).to eq(0)
      expect(result[:product_b][:score]).to eq(0)
    end
  end

  describe "Сложные сценарии" do
    it "обрабатывает продукт с повторяющимися добавками" do
      ingredients = "E621, глутамат натрия, E621"
      additives = NutriAnalyzer::Parser.parse(ingredients)

      expect(additives.size).to eq(1)
      expect(additives.first.code).to eq("E621")
    end

    it "корректно парсит состав в разных форматах" do
      formats = [
        "E621, E102, E322",
        "E-621, E-102, E-322",
        "E 621, E 102, E 322",
        "e621, e102, e322"
      ]

      formats.each do |ingredients|
        additives = NutriAnalyzer::Parser.parse(ingredients)
        expect(additives.size).to eq(3)
        expect(additives.map(&:code)).to contain_exactly("E621", "E102", "E322")
      end
    end

    it "обрабатывает продукт с неизвестными добавками" do
      ingredients = "E999, E888, E621"
      additives = NutriAnalyzer::Parser.parse(ingredients)

      expect(additives.size).to eq(1)
      expect(additives.first.code).to eq("E621")
    end

    it "генерирует предупреждения о суточной норме" do
      profile_with_weight = NutriAnalyzer::Profile.new(weight_kg: 70)
      ingredients = "E621"
      analyzer = NutriAnalyzer::Analyzer.new(
        NutriAnalyzer::Parser.parse(ingredients),
        profile_with_weight
      )
      result = analyzer.analyze

      expect(result[:warnings]).to include(
        include("Рекомендуемая суточная норма: 2100")
      )
    end

    it "комбинирует несколько типов предупреждений" do
      profile = NutriAnalyzer::Profile.new(
        allergies: ["соя"],
        age: 8,
        weight_kg: 70
      )
      ingredients = "E322, E102"
      analyzer = NutriAnalyzer::Analyzer.new(
        NutriAnalyzer::Parser.parse(ingredients),
        profile
      )
      result = analyzer.analyze

      expect(result[:dangerous].size).to eq(1)
      expect(result[:dangerous].first[:additive].code).to eq("E322")
      expect(result[:risky].size).to eq(1)
      expect(result[:risky].first[:additive].code).to eq("E102")

      warnings_text = result[:warnings].join(" ")
      expect(warnings_text).to include("Потенциальные риски: аллергия, гиперактивность у детей")
      expect(warnings_text).to include("Рекомендуемая суточная норма")
    end
  end

  describe "Работа с API (моки)" do
    it "интегрируется с внешним API через Nutrify" do
      # Создаём реальные данные продукта
      product_data = {
        "code" => "1234567890",
        "product_name" => "Test Product",
        "additives_tags" => ["en:e322"]
      }
      
      # Создаём реальный объект Product
      real_product = Nutrify::Product.new(product_data)
      
      # Мокируем метод analyze для любого экземпляра клиента
      allow_any_instance_of(Nutrify::Client).to receive(:analyze).and_return(real_product)
      
      client = Nutrify::Client.new
      product = client.analyze("1234567890")
      
      # Проверяем результат
      expect(product).to be_a(Nutrify::Product)
      expect(product.barcode).to eq("1234567890")
      expect(product.name).to eq("Test Product")
      expect(product.additives.size).to eq(1)
      expect(product.additives.first["name"]).to eq("Лецитин")
    end
  end

  describe "Сквозной сценарий использования" do
    it "выполняет полный анализ продукта от штрих-кода до отчёта" do
      product_data = {
        "code" => "3017620422003",
        "product_name" => "Nutella",
        "additives_tags" => ["en:e322"]
      }

      product = Nutrify::Product.new(product_data)
      ingredients = "лецитин (E322)"
      profile = NutriAnalyzer::Profile.new(
        allergies: ["соя"],
        diet: "none",
        age: 30
      )

      report = NutriAnalyzer.analyze_product(product.name, ingredients, profile)

      expect(report).to include("Nutella")
      expect(report).to include("Лецитин")
      expect(report).to include("Содержит аллерген(ы): соя")
      expect(report).to include("Опасные добавки")
    end
  end
end
