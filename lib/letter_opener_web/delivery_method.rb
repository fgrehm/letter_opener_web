# frozen_string_literal: true

require 'letter_opener/delivery_method'

module LetterOpenerWeb
  class DeliveryMethod < LetterOpener::DeliveryMethod
    def deliver!(mail)
      check_delivery_params(mail) if respond_to?(:check_delivery_params)
      location = File.join(settings[:location], "#{Time.now.to_f.to_s.tr('.', '_')}_#{Digest::SHA1.hexdigest(mail.encoded)[0..6]}")

      LetterOpener::Message.rendered_messages(mail, location: location, message_template: settings[:message_template])
    end
  end
end
