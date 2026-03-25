# lib/nutri_analyzer/report.rb
module NutriAnalyzer
  # Генерирует текстовый отчёт по результатам анализа
  class Report
    def self.generate(product_name, additives, analysis_result)
      report = []
      report << "=" * 50
      report << "Отчёт по продукту: #{product_name}"
      report << "=" * 50

      # Безопасные добавки
      if analysis_result[:safe].any?
        report << "\nБезопасные добавки:"
        analysis_result[:safe].each do |add|
          report << "  • #{add.name} (#{add.code}) — #{add.category}"
        end
      end

      # Потенциально рискованные
      if analysis_result[:risky].any?
        report << "\nДобавки с потенциальными рисками:"
        analysis_result[:risky].each do |item|
          add = item[:additive]
          report << "  • #{add.name} (#{add.code})"
          item[:reasons].each { |r| report << "    - #{r}" }
        end
      end

      # Опасные (с учётом профиля)
      if analysis_result[:dangerous].any?
        report << "\nОпасные добавки (не рекомендуются для вас):"
        analysis_result[:dangerous].each do |item|
          add = item[:additive]
          report << "  • #{add.name} (#{add.code})"
          item[:reasons].each { |r| report << "    - #{r}" }
        end
      end

      # Общие предупреждения
      if analysis_result[:warnings].any?
        report << "\nОбщие предупреждения:"
        analysis_result[:warnings].each { |w| report << "  • #{w}" }
      end

      report.join("\n")
    end
  end
end