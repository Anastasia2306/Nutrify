# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Nutrify Integration", :vcr do
  it "успешно получает данные продукта из API и расшифровывает добавки" do
    client = Nutrify::Client.new

    product = client.analyze("3017620422003")

    expect(product.name).to eq("Nutella")

    lecithin = product.additives.find { |a| a["name"] == "Лецитин" }
    expect(lecithin).not_to be_nil
    expect(lecithin["danger"]).to eq("low")
  end
end
