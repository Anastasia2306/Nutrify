# frozen_string_literal: true

require "spec_helper"
require_relative "../lib/nutrify/product"

RSpec.describe Nutrify::Product do
  let(:product) do
    Nutrify::Product.new(
      barcode: "123",
      name: "Test Product",
      additives: ["E330"],
      ingredients_text: "Sugar, Water"
    )
  end

  it "правильно сохраняет имя" do
    expect(product.name).to eq("Test Product")
  end

  it "правильно сохраняет добавки" do
    expect(product.additives).to eq(["E330"])
  end

  it "возвращает дефолтное имя, если оно nil" do
    p = Nutrify::Product.new(barcode: "000", name: nil)
    expect(p.name).to eq("Unknown Product")
  end
end
