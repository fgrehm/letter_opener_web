# frozen_string_literal: true

require 'letter_opener_web/version'
require 'letter_opener_web/engine'
require 'letter_opener_web/letter_interface'
require 'rexml/document'

module LetterOpenerWeb
  class Config
    attr_accessor :letters_location
    attr_writer :letter_class

    def letter_class
      @letter_class ||= LetterOpenerWeb::Letter
    end
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
  end
end
