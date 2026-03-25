# frozen_string_literal: true

module Nutrify
  ADDITIVES = {
    "E102" => {
      name: "Тартразин",
      category: "краситель",
      origin: "синтетическое",
      risks: ["аллергия", "гиперактивность у детей"],
      contraindications: ["астма", "непереносимость аспирина"],
      daily_limit_mg_per_kg: 7.5,
      allergens: []
    },
    "E322" => {
      name: "Лецитин",
      category: "эмульгатор",
      origin: "растительное",
      risks: [],
      contraindications: [],
      daily_limit_mg_per_kg: nil,
      allergens: ["соя"]
    }
  }.freeze
end
