# frozen_string_literal: true

require "spec_helper"

RSpec.describe NutriAnalyzer::Product do
  let(:name) { "Тестовый продукт" }
  let(:ingredients) { "Вода, сахар, E322, Тартразин" }

  it "сохраняет название и парсит добавки" do
    product = NutriAnalyzer::Product.new(name, ingredients)

    expect(product.name).to eq(name)
    # Проверяем коды
    codes = product.additives.map(&:code)
    expect(codes).to include("E322")
    expect(codes).to include("E102")
  end
end
