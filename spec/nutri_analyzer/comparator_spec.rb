# frozen_string_literal: true

require "spec_helper"

RSpec.describe NutriAnalyzer::Comparator do
  let(:profile) { NutriAnalyzer::Profile.new }

  def additive_for_code(code)
    NutriAnalyzer::Additive.find_by_code(code)
  end

  describe ".compare" do
    context "когда продукт А безопаснее" do
      # E621 имеет риски (головная боль, аллергия), E322 безопаснее
      let(:additives_a) { [additive_for_code("E322")] }  # безопасный лецитин
      let(:additives_b) { [additive_for_code("E621")] }  # рискованный глутамат

      it "определяет продукт А как лучший" do
        result = described_class.compare(additives_a, additives_b, profile)
        expect(result[:better]).to eq(:product_a)
        expect(result[:product_a][:score]).to be < result[:product_b][:score]
      end
    end

    context "когда продукт Б безопаснее" do
      # E621 имеет риски, E322 безопаснее
      let(:additives_a) { [additive_for_code("E621")] }  # рискованный глутамат
      let(:additives_b) { [additive_for_code("E322")] }  # безопасный лецитин

      it "определяет продукт Б как лучший" do
        result = described_class.compare(additives_a, additives_b, profile)
        expect(result[:better]).to eq(:product_b)
        expect(result[:product_b][:score]).to be < result[:product_a][:score]
      end
    end

    context "когда продукты одинаковы" do
      let(:additives_a) { [additive_for_code("E621")] }
      let(:additives_b) { [additive_for_code("E621")] }

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
      let(:additive_soy) { additive_for_code("E322") } # соевый лецитин
      let(:additive_safe) { additive_for_code("E621") } # глутамат без сои

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
