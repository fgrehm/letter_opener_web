# frozen_string_literal: true

require 'simplecov'
SimpleCov.start

if ENV.fetch('CI', '') == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require 'shoulda-matchers'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
