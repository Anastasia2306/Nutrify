# frozen_string_literal: true

require "spec_helper"

RSpec.describe NutriAnalyzer::Comparator do
  let(:profile) { NutriAnalyzer::Profile.new }
  let(:additive_a) { Nutrify::Additive.find_by_code("E621") }
  let(:additive_b) { Nutrify::Additive.find_by_code("E102") }

  describe ".compare" do
    context "когда продукт А безопаснее" do
      let(:additives_a) { [additive_a] }
      let(:additives_b) { [additive_b] }

      it "определяет продукт А как лучший" do
        result = described_class.compare(additives_a, additives_b, profile)
        expect(result[:better]).to eq(:product_a)
        expect(result[:product_a][:score]).to be < result[:product_b][:score]
      end
    end

    context "когда продукт Б безопаснее" do
      let(:additives_a) { [additive_b] }
      let(:additives_b) { [additive_a] }

      it "определяет продукт Б как лучший" do
        result = described_class.compare(additives_a, additives_b, profile)
        expect(result[:better]).to eq(:product_b)
        expect(result[:product_b][:score]).to be < result[:product_a][:score]
      end
    end

    context "когда продукты одинаковы" do
      let(:additives_a) { [additive_a] }
      let(:additives_b) { [additive_a] }

      it "определяет их как равные" do
        result = described_class.compare(additives_a, additives_b, profile)
        expect(result[:better]).to eq(:equal)
        expect(result[:product_a][:score]).to eq(result[:product_b][:score])
      end
    end

    context "с пустыми массивами" do
      it "сравнивает пустые продукты как равные" do
        result = described_class.compare([], [], profile)
        expect(result[:better]).to eq(:equal)
        expect(result[:product_a][:score]).to eq(0)
        expect(result[:product_b][:score]).to eq(0)
      end
    end

    context "с учётом профиля пользователя" do
      let(:profile_with_allergy) { NutriAnalyzer::Profile.new(allergies: ["соя"]) }
      let(:additive_soy) { Nutrify::Additive.find_by_code("E322") }
      let(:additive_safe) { Nutrify::Additive.find_by_code("E621") }

      it "учитывает аллергии при сравнении" do
        additives_a = [additive_soy]
        additives_b = [additive_safe]

        result = described_class.compare(additives_a, additives_b, profile_with_allergy)
        expect(result[:better]).to eq(:product_b)
        expect(result[:product_a][:dangerous]).to eq(1)
        expect(result[:product_b][:dangerous]).to eq(0)
      end
    end
  end
end
