# frozen_string_literal: true

require "nutrify"
require "vcr"
require "webmock/rspec"

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end

require_relative "../lib/nutri_analyzer/version"
require_relative "../lib/nutri_analyzer/additive"
require_relative "../lib/nutri_analyzer/parser"
require_relative "../lib/nutri_analyzer/profile"
require_relative "../lib/nutri_analyzer/analyzer"
require_relative "../lib/nutri_analyzer/report"
require_relative "../lib/nutri_analyzer/comparator"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
