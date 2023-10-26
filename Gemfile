# frozen_string_literal: true

source "https://rubygems.org"

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in web_pipe.gemspec
gemspec

group :development do
  gem "dry-schema", "~> 1.0"
  gem "dry-transformer", "~> 0.1"
  gem "pry-byebug"
  gem "rack-flash3", "~> 1.0"
  gem "rack-test", "~> 1.1"
  gem "rake", "~> 12.3", ">= 12.3.3"
  gem "redcarpet", "~> 3.4"
  gem "rspec", "~> 3.0"
  gem "rubocop", "~> 1.8"
  gem "rubocop-rspec", "~> 2.1"
  gem "yard", "~> 0.9", ">= 0.9.20"
  # TODO: Move to gemspec when hanami-view 2.0 is available
  gem "hanami-view", github: "hanami/view", tag: "v2.1.0.beta2"
end

group :test do
  gem "simplecov", require: false
end
