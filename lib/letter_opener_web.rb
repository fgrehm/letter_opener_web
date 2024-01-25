# frozen_string_literal: true

require 'letter_opener_web/version'
require 'letter_opener_web/engine'
require 'rexml/document'
require 'aws-sdk-s3'

module LetterOpenerWeb
  class Config
    attr_accessor :letters_location, :aws_access_key_id, :aws_secret_access_key, :aws_region, :aws_bucket
  end

  def self.config
    @config ||= Config.new.tap do |conf|
      conf.letters_location = Rails.root.join('tmp', 'letter_opener')
    end
  end

  def self.configure
    yield config if block_given?
  end

  def self.reset!
    @config = nil
    @aws_client = nil
  end

  def self.aws_client
    @aws_client ||= ::Aws::S3::Client.new(
      access_key_id: LetterOpenerWeb.config.aws_access_key_id,
      secret_access_key: LetterOpenerWeb.config.aws_secret_access_key,
      region: LetterOpenerWeb.config.aws_region
    )
  end
end
