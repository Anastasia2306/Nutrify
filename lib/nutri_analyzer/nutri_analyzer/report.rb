# frozen_string_literal: true

# lib/nutri_analyzer/report.rb
module NutriAnalyzer
  # Генерирует текстовый отчёт по результатам анализа
  class Report
    def self.generate(product_name, _additives, analysis_result)
      report = []
      add_header(report, product_name)
      add_section(report, "Безопасные добавки:", analysis_result[:safe]) do |add|
        "  • #{add.name} (#{add.code}) — #{add.category}"
      end
      add_risky_section(report, analysis_result[:risky])
      add_dangerous_section(report, analysis_result[:dangerous])
      add_warnings_section(report, analysis_result[:warnings])
      report.join("\n")
    end

    def self.add_header(report, product_name)
      report << ("=" * 50)
      report << "Отчёт по продукту: #{product_name}"
      report << ("=" * 50)
    end
    private_class_method :add_header

    def self.add_section(report, title, items, &formatter)
      return if items.empty?

      report << "\n#{title}"
      items.each { |item| report << formatter.call(item) }
    end
    private_class_method :add_section

    def self.add_risky_section(report, risky_items)
      return if risky_items.empty?

      report << "\nДобавки с потенциальными рисками:"
      risky_items.each do |item|
        add = item[:additive]
        report << "  • #{add.name} (#{add.code})"
        item[:reasons].each { |r| report << "    - #{r}" }
      end
    end
    private_class_method :add_risky_section

    def self.add_dangerous_section(report, dangerous_items)
      return if dangerous_items.empty?

      report << "\nОпасные добавки (не рекомендуются для вас):"
      dangerous_items.each do |item|
        add = item[:additive]
        report << "  • #{add.name} (#{add.code})"
        item[:reasons].each { |r| report << "    - #{r}" }
      end
    end
    private_class_method :add_dangerous_section

    def self.add_warnings_section(report, warnings)
      return if warnings.empty?

      report << "\nОбщие предупреждения:"
      warnings.each { |w| report << "  • #{w}" }
    end
    private_class_method :add_warnings_section
  end
end
