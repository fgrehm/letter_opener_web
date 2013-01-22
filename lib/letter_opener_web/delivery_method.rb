require 'letter_opener/delivery_method'

module LetterOpenerWeb
  class DeliveryMethod < LetterOpener::DeliveryMethod
    # "Replaces" original Launchy constant with a noop one
    module Launchy; def open; end; end
  end
end
