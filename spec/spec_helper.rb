# frozen_string_literal: true

require "nutrify"

require_relative "../lib/nutri_analyzer/version"
require_relative "../lib/nutri_analyzer/additive"
require_relative "../lib/nutri_analyzer/parser"
require_relative "../lib/nutri_analyzer/profile"
require_relative "../lib/nutri_analyzer/analyzer"
require_relative "../lib/nutri_analyzer/report"
require_relative "../lib/nutri_analyzer/comparator"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
