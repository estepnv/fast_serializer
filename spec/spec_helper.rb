# frozen_string_literal: true

if !!ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter /spec/
  end
  puts 'SimpleCov started successfully!'
end

require 'bundler/setup'
require 'fast_serializer'
require 'factory_bot'
require 'faker'
require 'rspec-benchmark'
require 'active_model_serializers'
require 'active_support/core_ext/object/deep_dup'

Dir['./spec/models/**/*.rb'].each { |f| require f }
Dir['./spec/support/**/*.rb'].each { |f| require f }

RSpec::Benchmark.configure do |config|
  config.disable_gc = true
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.include FactoryBot::Syntax::Methods
  config.include RSpec::Benchmark::Matchers

  config.before(:suite) { FactoryBot.find_definitions }

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
