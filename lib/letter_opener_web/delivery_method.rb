require 'letter_opener/delivery_method'

module LetterOpenerWeb
  class DeliveryMethod < LetterOpener::DeliveryMethod
    def deliver!(mail)
      location = File.join(settings[:location], "#{Time.now.to_i}_#{Digest::SHA1.hexdigest(mail.encoded)[0..6]}")
      LetterOpener::Message.rendered_messages(location, mail)
      # Launchy.open(URI.parse(URI.escape(messages.first.filepath)))
    end
  end
end
