# frozen_string_literal: true

require "nutrify"
require "nutri_analyzer"

require_relative "../lib/nutri_analyzer"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
