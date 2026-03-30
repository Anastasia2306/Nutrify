# frozen_string_literal: true

require "spec_helper"

RSpec.describe NutriAnalyzer::Profile do
  let(:default_profile) { described_class.new }

  describe "#initialize" do
    it "создаёт профиль со значениями по умолчанию" do
      expect(default_profile.allergies).to eq([])
      expect(default_profile.diet).to eq("none")
      expect(default_profile.age).to be_nil
      expect(default_profile.chronic_diseases).to eq([])
      expect(default_profile.weight_kg).to be_nil
    end

    it "приводит все входящие строки к нижнему регистру (нормализация)" do
      profile = described_class.new(
        allergies: %w[Соя Глютен],
        diet: "VEGAN",
        chronic_diseases: %w[Астма ДИАБЕТ]
      )

      expect(profile.allergies).to eq(%w[соя глютен])
      expect(profile.diet).to eq("vegan")
      expect(profile.chronic_diseases).to eq(%w[астма диабет])
    end
  end

  describe "#allergic_to?" do
    let(:profile) { described_class.new(allergies: %w[соя арахис]) }

    it "игнорирует регистр при проверке аллергии" do
      expect(profile.allergic_to?("СОЯ")).to be true
      expect(profile.allergic_to?("Арахис")).to be true
    end
  end

  describe "#contraindication?" do
    let(:profile) { described_class.new(chronic_diseases: %w[астма диабет]) }

    it "возвращает true при совпадении" do
      profile = described_class.new(chronic_diseases: ["астма"])
      expect(profile.contraindication?("астма")).to be true
    end

    it "корректно работает с разным регистром в базе" do
      expect(profile.contraindication?("АСТМА")).to be true
    end

    it "возвращает false, если совпадений нет" do
      expect(profile.contraindication?("здоров как бык")).to be false
    end
  end

  describe "#max_safe_daily_mg" do
    let(:additive) { NutriAnalyzer::Additive.find_by_code("E621") }

    it "верно рассчитывает дозу (30 * 70 = 2100)" do
      profile = described_class.new(weight_kg: 70)
      expect(profile.max_safe_daily_mg(additive)).to eq(2100.0)
    end

    it "возвращает nil, если лимит в добавке не указан" do
      safe_additive = NutriAnalyzer::Additive.find_by_code("E330")
      profile = described_class.new(weight_kg: 70)
      expect(profile.max_safe_daily_mg(safe_additive)).to be_nil
    end
  end

  describe "#child?" do
    it "считает ребенком пользователя до 12 лет" do
      expect(described_class.new(age: 11).child?).to be true
      expect(described_class.new(age: 12).child?).to be false
    end
  end
end
