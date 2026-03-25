# lib/nutri_analyzer/analyzer.rb
module NutriAnalyzer
  # Анализирует список добавок с учётом профиля пользователя
  class Analyzer
    attr_reader :additives, :profile

    def initialize(additives, profile = nil)
      @additives = additives
      @profile = profile || Profile.new
    end

    # Основная оценка: возвращает хеш с результатами анализа
    def analyze
      result = {
        safe: [],
        risky: [],
        dangerous: [],
        warnings: []
      }

      additives.each do |add|
        risks = evaluate_additive(add)
        if risks[:dangerous]
          result[:dangerous] << { additive: add, reasons: risks[:reasons] }
        elsif risks[:risky]
          result[:risky] << { additive: add, reasons: risks[:reasons] }
        else
          result[:safe] << add
        end
        result[:warnings].concat(risks[:warnings]) if risks[:warnings]
      end

      result
    end

    private

    def evaluate_additive(add)
      reasons = []
      warnings = []
      dangerous = false
      risky = false

      # Проверка на аллергены
      if add.allergens.any? { |a| profile.allergic_to?(a) }
        reasons << "Содержит аллерген(ы): #{add.allergens.join(', ')}"
        dangerous = true
      end

      # Проверка на совместимость с диетой
      unless profile.diet_compatible?(add.origin)
        reasons << "Происхождение '#{add.origin}' не соответствует диете '#{profile.diet}'"
        dangerous = true
      end

      # Проверка противопоказаний по хроническим заболеваниям
      add.contraindications.each do |c|
        if profile.has_contraindication?(c)
          reasons << "Противопоказано при #{c}"
          dangerous = true
        end
      end

      # Риски для детей
      if profile.child? && add.risks.any? { |r| r.include?("дети") }
        warnings << "Данная добавка может быть опасна для детей: #{add.risks.join(', ')}"
        risky = true
      end

      # Превышение суточной нормы (требует информации о количестве добавки)
      # Для демонстрации: если есть дневной лимит и вес, предупреждаем
      if add.daily_limit_mg_per_kg && profile.weight_kg
        max_mg = profile.max_safe_daily_mg(add)
        # Мы не знаем точное количество в продукте, поэтому просто уведомляем о существовании лимита.
        warnings << "Рекомендуемая суточная норма: #{max_mg} мг (для вашего веса)" if max_mg
      end

      # Общие риски
      if add.risks.any?
        warnings << "Потенциальные риски: #{add.risks.join(', ')}"
        risky = true unless dangerous
      end

      { dangerous: dangerous, risky: risky, reasons: reasons, warnings: warnings }
    end
  end
end