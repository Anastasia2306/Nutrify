# frozen_string_literal: true

require "spec_helper"

RSpec.describe NutriAnalyzer::Analyzer do
  let(:default_profile) { NutriAnalyzer::Profile.new }

  describe "#initialize" do
    it "создаёт анализатор с добавками" do
      additives = [Nutrify::Additive.find_by_code("E621")]
      analyzer = described_class.new(additives)
      expect(analyzer.additives).to eq(additives)
    end

    it "использует профиль по умолчанию" do
      additives = [Nutrify::Additive.find_by_code("E621")]
      analyzer = described_class.new(additives)
      expect(analyzer.profile).to be_a(NutriAnalyzer::Profile)
    end
  end

  describe "#analyze" do
    context "с безопасными добавками" do
      let(:additives) { [Nutrify::Additive.find_by_code("E322")] }
      let(:analyzer) { described_class.new(additives, default_profile) }

      it "отмечает добавку как безопасную" do
        result = analyzer.analyze
        expect(result[:safe]).to include(additives.first)
        expect(result[:risky]).to be_empty
        expect(result[:dangerous]).to be_empty
      end
    end

    context "с аллергией" do
      let(:profile) { NutriAnalyzer::Profile.new(allergies: ["соя"]) }
      let(:additives) { [Nutrify::Additive.find_by_code("E322")] }
      let(:analyzer) { described_class.new(additives, profile) }

      it "отмечает добавку как опасную" do
        result = analyzer.analyze
        expect(result[:dangerous].size).to eq(1)
        expect(result[:dangerous].first[:additive].code).to eq("E322")
      end
    end

    context "с противопоказаниями" do
      let(:profile) { NutriAnalyzer::Profile.new(chronic_diseases: ["астма"]) }
      let(:additives) { [Nutrify::Additive.find_by_code("E102")] }
      let(:analyzer) { described_class.new(additives, profile) }

      it "отмечает добавку как опасную" do
        result = analyzer.analyze
        expect(result[:dangerous].size).to eq(1)
      end
    end

    context "с рисками для детей" do
      let(:profile) { NutriAnalyzer::Profile.new(age: 8) }
      let(:additives) { [Nutrify::Additive.find_by_code("E102")] }
      let(:analyzer) { described_class.new(additives, profile) }

      it "отмечает добавку как рискованную" do
        result = analyzer.analyze
        expect(result[:risky].size).to eq(1)
        expect(result[:warnings]).not_to be_empty
      end
    end

    context "с пустым списком" do
      let(:analyzer) { described_class.new([], default_profile) }

      it "возвращает пустые категории" do
        result = analyzer.analyze
        expect(result[:safe]).to be_empty
        expect(result[:risky]).to be_empty
        expect(result[:dangerous]).to be_empty
      end
    end
  end
end
