# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development, :test do
  gem 'rake'
  gem 'pry'
end

group :test do
  gem 'active_model_serializers'
  gem 'factory_bot'
  gem 'faker'
  gem 'activesupport'
  gem 'allocation_stats'
  gem 'simplecov'
  gem 'benchmark-memory'
  gem 'rspec'
  gem 'rspec-benchmark'
end
