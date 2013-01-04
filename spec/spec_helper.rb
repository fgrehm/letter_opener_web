require 'rubygems'
require 'bundler'

Bundler.require :default, :test

require 'capybara/rspec'

Combustion.initialize!

require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
end
