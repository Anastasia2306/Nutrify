# frozen_string_literal: true

require "spec_helper"

RSpec.describe NutriAnalyzer::Report do
  let(:additives) do
    [
      Nutrify::Additive.find_by_code("E621"),
      Nutrify::Additive.find_by_code("E322")
    ]
  end

  describe ".generate" do
    let(:analysis_result) do
      {
        safe: [additives[1]],
        risky: [],
        dangerous: [],
        warnings: []
      }
    end

    it "генерирует отчёт с названием продукта" do
      report = described_class.generate("Тестовый продукт", additives, analysis_result)
      expect(report).to include("Тестовый продукт")
      expect(report).to include("Безопасные добавки")
    end

    it "включает безопасные добавки" do
      report = described_class.generate("Тест", additives, analysis_result)
      expect(report).to include("Лецитин")
      expect(report).to include("E322")
    end

    it "не включает пустые категории" do
      report = described_class.generate("Тест", additives, analysis_result)
      expect(report).not_to include("Добавки с потенциальными рисками")
      expect(report).not_to include("Опасные добавки")
    end

    it "включает рискованные добавки" do
      risky_result = {
        safe: [],
        risky: [{ additive: additives[0], reasons: ["Потенциальный риск"] }],
        dangerous: [],
        warnings: []
      }

      report = described_class.generate("Тест", additives, risky_result)
      expect(report).to include("Добавки с потенциальными рисками")
      expect(report).to include("Глутамат натрия")
    end

    it "включает опасные добавки" do
      dangerous_result = {
        safe: [],
        risky: [],
        dangerous: [{ additive: additives[0], reasons: ["Аллергия"] }],
        warnings: []
      }

      report = described_class.generate("Тест", additives, dangerous_result)
      expect(report).to include("Опасные добавки")
      expect(report).to include("Аллергия")
    end

    it "включает предупреждения" do
      warning_result = {
        safe: [],
        risky: [],
        dangerous: [],
        warnings: ["Тестовое предупреждение"]
      }

      report = described_class.generate("Тест", additives, warning_result)
      expect(report).to include("Общие предупреждения")
      expect(report).to include("Тестовое предупреждение")
    end
  end
end
