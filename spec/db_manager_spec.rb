# frozen_string_literal: true

RSpec.describe Nutrify::DbManager do
  it "находит существующую добавку в YAML" do
    info = Nutrify::DbManager.find("en:e322")

    expect(info["name"]).to eq("Лецитин")
    expect(info["danger"]).to eq("low")
  end

  it "возвращает дефолтные значения для неизвестного кода" do
    info = Nutrify::DbManager.find("unknown_code")

    expect(info["name"]).to eq("unknown_code")
    expect(info["description"]).to eq("Нет данных")
  end
end
