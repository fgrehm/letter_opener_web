# frozen_string_literal: true

module LetterOpenerWeb
  class AwsLetter < LetterOpenerWeb::Letter
    def self.search
      letters = LetterOpenerWeb.aws_client.list_objects_v2(bucket: LetterOpenerWeb.config.aws_bucket, delimiter: '/').common_prefixes.map do |folder|
        new(id: folder.prefix.gsub('/', ''))
      end

      letters.reverse
    end

    def self.destroy_all
      letters = LetterOpenerWeb.aws_client.list_objects_v2(bucket: LetterOpenerWeb.config.aws_bucket).contents.map(&:key)

      LetterOpenerWeb.aws_client.delete_objects(
        bucket: LetterOpenerWeb.config.aws_bucket,
        delete: {
          objects: letters.map { |key| { key: key } },
          quiet: false
        }
      )
    end

    def initialize(params)
      @id = params.fetch(:id)
    end

    def attachments
      @attachments ||= LetterOpenerWeb.aws_client.list_objects_v2(
        bucket: LetterOpenerWeb.config.aws_bucket, prefix: "#{@id}/attachments/"
      ).contents.each_with_object({}) do |file, hash|
        hash[File.basename(file.key)] = attachment_url(file.key)
      end
    end

    def delete
      return unless valid?

      letters = LetterOpenerWeb.aws_client.list_objects_v2(bucket: LetterOpenerWeb.config.aws_bucket, prefix: @id).contents.map(&:key)

      LetterOpenerWeb.aws_client.delete_objects(
        bucket: LetterOpenerWeb.config.aws_bucket,
        delete: {
          objects: letters.map { |key| { key: key } },
          quiet: false
        }
      )
    end

    def valid?
      LetterOpenerWeb.aws_client.list_objects_v2(bucket: LetterOpenerWeb.config.aws_bucket, prefix: @id).contents.any?
    end

    private

    def attachment_url(key)
      bucket = Aws::S3::Bucket.new(
        name: LetterOpenerWeb.config.aws_bucket, client: LetterOpenerWeb.aws_client
      )

      obj = bucket.object(key)
      obj.presigned_url(:get, expires_in: 1.week.to_i)
    end

    def objects
      @objects ||= {}
    end

    def read_file(style)
      return objects[style] if objects.key?(style)

      response = LetterOpenerWeb.aws_client.get_object(bucket: LetterOpenerWeb.config.aws_bucket, key: "#{@id}/#{style}.html")

      response.body.read.tap do |value|
        objects[style] = value
      end
    rescue Aws::S3::Errors::NoSuchKey
      ''
    end

    def style_exists?(style)
      return !objects[style].empty? if objects.key?(style)

      objects[style] = read_file(style)
      !objects[style].empty?
    end
  end
end
