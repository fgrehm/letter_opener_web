# frozen_string_literal: true

require 'letter_opener/delivery_method'

module LetterOpenerWeb
  class DeliveryMethod < LetterOpener::DeliveryMethod
    def deliver!(mail)
      ENV['LAUNCHY_DRY_RUN'] = 'true'
      super
      ENV['LAUNCHY_DRY_RUN'] = 'false'
    end
  end
end
