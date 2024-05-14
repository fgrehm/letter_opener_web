# frozen_string_literal: true

require 'letter_opener/delivery_method'

module LetterOpenerWeb
  class DeliveryMethod < LetterOpener::DeliveryMethod
    def deliver!(mail)
      original = ENV.fetch('LAUNCHY_DRY_RUN', nil)
      ENV['LAUNCHY_DRY_RUN'] = 'true'
      
      if LetterOpenerWeb.config.letters_location == :s3
        validate_mail!(mail)
        location = "#{Time.now.to_f.to_s.tr('.', '_')}_#{Digest::SHA1.hexdigest(mail.encoded)[0..6]}"

        messages = LetterOpenerWeb::S3Message.rendered_messages(mail, location: location, message_template: settings[:message_template])
      else
        super
      end
    rescue Launchy::CommandNotFoundError
      # Ignore for non-executable Launchy environment.
    ensure
      ENV['LAUNCHY_DRY_RUN'] = original
    end
  end
end
