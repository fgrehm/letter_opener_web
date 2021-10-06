# frozen_string_literal: true

require 'letter_opener/delivery_method'

module LetterOpenerWeb
  class DeliveryMethod < LetterOpener::DeliveryMethod
    def deliver!(mail)
      original = ENV['LAUNCHY_DRY_RUN']
      ENV['LAUNCHY_DRY_RUN'] = 'true'

      super
    rescue Launchy::CommandNotFoundError
      # Ignore for non-executable Launchy environment.
    ensure
      ENV['LAUNCHY_DRY_RUN'] = original
    end
  end
end
