require 'rubygems'
require 'bundler'

Bundler.require :default, :test

require 'capybara/rspec'

Combustion.initialize!

require 'rspec/rails'
require 'capybara/rails'

RSpec.configure do |config|
  config.use_transactional_fixtures = true

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
