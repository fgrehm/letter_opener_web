# frozen_string_literal: true

class ContactMailer < ApplicationMailer
  default to: 'admin@letter_opener_web.org', from: 'no-reply@letter_opener_web.org'

  def new_message(from, message, attachment)
    @from    = from
    @message = message

    attachments[attachment.original_filename] = attachment.tempfile.read if attachment.present?

    mail(subject: 'Testing letter_opener_web')
  end
end
