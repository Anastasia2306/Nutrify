# frozen_string_literal: true

require "spec_helper"

RSpec.describe NutriAnalyzer::Report do
  def additive_for_code(code)
    NutriAnalyzer::Additive.find_by_code(code)
  end

  let(:additives) do
    [
      additive_for_code("E621"),
      additive_for_code("E322")
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

    it "генерирует отчёт с названием продукта и разделителями" do
      report = described_class.generate("Тестовый продукт", additives, analysis_result)
      expect(report).to include("Тестовый продукт")
      expect(report).to include("=" * 50)
      expect(report).to include("Безопасные добавки")
    end

    it "включает безопасные добавки с их категориями" do
      report = described_class.generate("Тест", additives, analysis_result)
      expect(report).to include("Лецитин")
      expect(report).to include("E322")
      expect(report).to include("эмульгатор")
    end

    context "визуальная маркировка (значки)" do
      it "использует знак [?] для рискованных добавок" do
        risky_result = {
          safe: [],
          risky: [{ additive: additives[0], reasons: ["Потенциальный риск"] }],
          dangerous: [],
          warnings: []
        }

        report = described_class.generate("Тест", additives, risky_result)
        expect(report).to include("[?] Глутамат натрия")
        expect(report).to include("Добавки с потенциальными рисками")
      end

      it "использует знак [!] для опасных добавок" do
        dangerous_result = {
          safe: [],
          risky: [],
          dangerous: [{ additive: additives[0], reasons: ["Аллергия"] }],
          warnings: []
        }

        report = described_class.generate("Тест", additives, dangerous_result)
        expect(report).to include("[!] Глутамат натрия")
        expect(report).to include("Опасные добавки")
      end
    end

    it "не включает пустые секции (для чистоты отчёта)" do
      report = described_class.generate("Тест", additives, analysis_result)
      expect(report).not_to include("Добавки с потенциальными рисками")
      expect(report).not_to include("Опасные добавки")
    end

    it "правильно форматирует общие предупреждения" do
      warning_result = {
        safe: [],
        risky: [],
        dangerous: [],
        warnings: ["Риск накопления в организме"]
      }

      report = described_class.generate("Тест", additives, warning_result)
      expect(report).to include("Общие предупреждения")
      expect(report).to include("• Риск накопления в организме")
    end
  end
end
