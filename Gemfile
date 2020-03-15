# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gemspec

group :development do
  gem 'rake'
  gem 'pry-byebug', '~> 3.7.0'
  gem 'pry'
end

group :test do
  gem 'active_model_serializers', '~> 0.10.0'
  gem 'factory_bot'
  gem 'faker'
  gem 'activesupport', '< 6'
  gem 'allocation_stats'
  gem 'simplecov', '~> 0.17.1'
  gem 'benchmark-memory', '~> 0.1'
  gem 'rspec', '~> 3.0'
  gem 'rspec-benchmark'
end
