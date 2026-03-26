# frozen_string_literal: true

require "spec_helper"

RSpec.describe NutriAnalyzer::Profile do
  let(:default_profile) { described_class.new }

  describe "#initialize" do
    it "создаёт профиль с значениями по умолчанию" do
      expect(default_profile.allergies).to eq([])
      expect(default_profile.diet).to eq("none")
      expect(default_profile.age).to be_nil
      expect(default_profile.chronic_diseases).to eq([])
      expect(default_profile.weight_kg).to be_nil
    end

    it "принимает все параметры" do
      profile = described_class.new(
        allergies: %w[соя глютен],
        diet: "vegan",
        age: 25,
        chronic_diseases: ["астма"],
        weight_kg: 70.5
      )

      expect(profile.allergies).to eq(%w[соя глютен])
      expect(profile.diet).to eq("vegan")
      expect(profile.age).to eq(25)
      expect(profile.chronic_diseases).to eq(["астма"])
      expect(profile.weight_kg).to eq(70.5)
    end

    it "приводит строки к нижнему регистру" do
      profile = described_class.new(
        allergies: %w[Соя Глютен],
        diet: "VEGAN",
        chronic_diseases: ["Астма"]
      )

      expect(profile.allergies).to eq(%w[соя глютен])
      expect(profile.diet).to eq("vegan")
      expect(profile.chronic_diseases).to eq(["астма"])
    end
  end

  describe "#allergic_to?" do
    let(:profile) { described_class.new(allergies: %w[соя арахис]) }

    it "возвращает true для аллергена в списке" do
      expect(profile.allergic_to?("соя")).to be true
      expect(profile.allergic_to?("арахис")).to be true
    end

    it "возвращает false для аллергена не в списке" do
      expect(profile.allergic_to?("глютен")).to be false
    end

    it "игнорирует регистр" do
      expect(profile.allergic_to?("СОЯ")).to be true
    end
  end

  describe "#diet_compatible?" do
    context "с диетой vegan" do
      let(:profile) { described_class.new(diet: "vegan") }

      it "разрешает растительное происхождение" do
        expect(profile.diet_compatible?("растительное")).to be true
      end

      it "запрещает животное происхождение" do
        expect(profile.diet_compatible?("животное")).to be false
      end
    end

    context "с диетой vegetarian" do
      let(:profile) { described_class.new(diet: "vegetarian") }

      it "разрешает растительное" do
        expect(profile.diet_compatible?("растительное")).to be true
      end

      it "запрещает животное" do
        expect(profile.diet_compatible?("животное")).to be false
      end
    end

    context "без диеты" do
      let(:profile) { described_class.new(diet: "none") }

      it "разрешает любое происхождение" do
        expect(profile.diet_compatible?("животное")).to be true
        expect(profile.diet_compatible?("растительное")).to be true
      end
    end
  end

  describe "#contraindication?" do
    let(:profile) { described_class.new(chronic_diseases: %w[астма диабет]) }

    it "возвращает true при частичном совпадении" do
      expect(profile.contraindication?("астма")).to be true
      expect(profile.contraindication?("бронхиальная астма")).to be true
    end

    it "возвращает false при отсутствии совпадения" do
      expect(profile.contraindication?("аллергия")).to be false
    end
  end

  describe "#child?" do
    it "возвращает true для возраста меньше 12" do
      profile = described_class.new(age: 8)
      expect(profile.child?).to be true
    end

    it "возвращает false для возраста 12 и старше" do
      profile = described_class.new(age: 30)
      expect(profile.child?).to be false
    end
  end

  describe "#max_safe_daily_mg" do
    let(:additive) { NutriAnalyzer::Additive.find_by_code("E621") }
    let(:profile) { described_class.new(weight_kg: 70) }

    it "рассчитывает безопасную дозу" do
      expect(profile.max_safe_daily_mg(additive)).to eq(2100.0)
    end

    it "возвращает nil если нет веса" do
      profile_without_weight = described_class.new
      expect(profile_without_weight.max_safe_daily_mg(additive)).to be_nil
    end
  end
end
