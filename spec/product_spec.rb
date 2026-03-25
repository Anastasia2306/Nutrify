# frozen_string_literal: true

require "spec_helper"

RSpec.describe Nutrify::Product do
  let(:fake_api_data) do
    {
      "code" => "3017620422003",
      "product_name" => "Nutella",
      "additives_tags" => ["en:e322"]
    }
  end

  it "сохраняет штрих-код и название" do
    product = Nutrify::Product.new(fake_api_data)

    expect(product.barcode).to eq("3017620422003")
    expect(product.name).to eq("Nutella")
  end

  it "расшифровывает добавки через DbManager" do
    product = Nutrify::Product.new(fake_api_data)

    expect(product.additives).to be_an(Array)
    expect(product.additives.first["name"]).to eq("Лецитин")
  end
end
