# frozen_string_literal: true

require 'letter_opener_web/engine'
require 'rexml/document'

module LetterOpenerWeb
  class Config
    attr_accessor :letters_location
    attr_accessor :base_controller
  end

  def self.config
    @config ||= Config.new.tap do |conf|
      conf.letters_location = Rails.root.join('tmp', 'letter_opener')
      conf.base_controller = ApplicationController
    end
  end

  def self.configure
    yield config if block_given?
  end

  def self.reset!
    @config = nil
  end
end
