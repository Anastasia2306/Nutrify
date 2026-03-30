# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Nutrify Integration" do
  it "успешно получает данные продукта и расшифровывает добавки" do
    product_name = "Nutella"
    ingredients = "лецитин (E322)"
    profile = NutriAnalyzer::Profile.new(allergies: ["соя"])

    report = NutriAnalyzer.analyze_product(product_name, ingredients, profile)

    expect(report).to include("Nutella")
    expect(report).to include("Лецитин")
    expect(report).to include("Содержит аллерген(ы): соя")
  end
end
