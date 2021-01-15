# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in web_pipe.gemspec
gemspec

# TODO: Remove when dry-rb 0.8 is released (ruby 3.0 support)
group :development do
  gem 'dry-view', github: 'dry-rb/dry-view', ref: 'a048e32'
end
