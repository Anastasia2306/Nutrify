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

      it "возвращает пустой массив для строки с пробелами" do
        expect(described_class.parse("   ")).to eq([])
      end
    end

    context "с E-кодами" do
      it "находит E621" do
        additives = described_class.parse("состав: E621")
        expect(additives.size).to eq(1)
        expect(additives.first.code).to eq("E621")
      end

      it "находит E102" do
        additives = described_class.parse("E102")
        expect(additives.size).to eq(1)
        expect(additives.first.code).to eq("E102")
      end

      it "находит E322" do
        additives = described_class.parse("E322")
        expect(additives.size).to eq(1)
        expect(additives.first.code).to eq("E322")
      end

      it "работает с пробелом после E" do
        additives = described_class.parse("E 621")
        expect(additives.size).to eq(1)
        expect(additives.first.code).to eq("E621")
      end

      it "работает с дефисом после E" do
        additives = described_class.parse("E-621")
        expect(additives.size).to eq(1)
        expect(additives.first.code).to eq("E621")
      end
    end

    context "с несколькими E-кодами" do
      it "находит несколько E-кодов" do
        additives = described_class.parse("E621, E102, E322")
        expect(additives.size).to eq(3)
        expect(additives.map(&:code)).to contain_exactly("E621", "E102", "E322")
      end

      it "игнорирует регистр" do
        additives = described_class.parse("e621")
        expect(additives.size).to eq(1)
        expect(additives.first.code).to eq("E621")
      end

      it "не добавляет несуществующие коды" do
        additives = described_class.parse("E999")
        expect(additives).to be_empty
      end
    end

    context "с текстовыми названиями" do
      it "находит глутамат натрия" do
        additives = described_class.parse("содержит глутамат натрия")
        expect(additives.size).to eq(1)
        expect(additives.first.code).to eq("E621")
      end

      it "находит тартразин" do
        additives = described_class.parse("тартразин")
        expect(additives.size).to eq(1)
        expect(additives.first.code).to eq("E102")
      end

      it "находит лецитин" do
        additives = described_class.parse("лецитин")
        expect(additives.size).to eq(1)
        expect(additives.first.code).to eq("E322")
      end
    end

    context "с комбинированным вводом" do
      it "не создаёт дубликаты" do
        additives = described_class.parse("E621 (глутамат натрия)")
        expect(additives.size).to eq(1)
        expect(additives.first.code).to eq("E621")
      end

      it "обрабатывает сложный состав" do
        text = "Состав: вода, E621, лецитин (Е322), тартразин E102"
        additives = described_class.parse(text)
        expect(additives.size).to eq(3)
        expect(additives.map(&:code)).to contain_exactly("E621", "E322", "E102")
      end
    end
  end
end
