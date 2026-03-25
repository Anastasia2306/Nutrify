# frozen_string_literal: true

require_relative "lib/nutrify/version"

Gem::Specification.new do |spec|
  spec.name = "Nutrify"
  spec.version = Nutrify::VERSION
  spec.authors = %w[Anastasia Polina]
  spec.email = ["anastasia@1c-developer.ru", "dyatlowskaya.polina@yandex.ru"]

  spec.summary = "Анализатор пищевых добавок и нутрицевтиков"
  spec.description = "Поиск вредных Е-добавок через OpenFoodFacts API"
  spec.homepage = "https://github.com/Anastasia2306/Nutrify"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", "~> 2.0"
end
