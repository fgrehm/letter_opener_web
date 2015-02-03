require 'rubygems'
require 'bundler/setup'

require 'combustion'
Bundler.require :default, :test

Combustion.initialize! :action_controller, :action_view, :action_mailer

require 'rspec/rails'
require 'shoulda-matchers'

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  config.infer_spec_type_from_file_location!

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
