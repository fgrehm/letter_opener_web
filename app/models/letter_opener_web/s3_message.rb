# frozen_string_literal: true

module LetterOpenerWeb
  class S3Message < LetterOpener::Message
    def render
      mail.attachments.each do |attachment|
        filename = attachment_filename(attachment)

        LetterOpenerWeb.aws_client.put_object(
          bucket: LetterOpenerWeb.config.aws_bucket,
          key: "#{@location}/attachments/#{filename}",
          body: attachment.body.raw_source
        )

        @attachments << [attachment.filename, "attachments/#{filename}"]
      end

      LetterOpenerWeb.aws_client.put_object(
        bucket: LetterOpenerWeb.config.aws_bucket,
        key: "#{@location}/#{type}.html",
        body: ERB.new(template).result(binding)
      )
    end
  end
end
