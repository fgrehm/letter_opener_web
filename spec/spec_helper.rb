# frozen_string_literal: true

require 'shoulda-matchers'

RSpec.configure do |config|
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
