# frozen_string_literal: true

require 'letter_opener_web/version'
require 'letter_opener_web/engine'
require 'rexml/document'

module LetterOpenerWeb
  class Config
    attr_accessor :letters_location, :auto_dark_mode, :authentication_enabled, :username, :password

    def basic_auth_enabled?
      authentication_enabled && username.present? && password.present?
    end

    def warn_if_basic_auth_misconfigured
      return unless authentication_enabled && (username.blank? || password.blank?)

      Rails.logger.warn('[LetterOpenerWeb] authentication_enabled is true but username or password is blank. ' \
                        'Basic auth will not be enforced.')
    end
  end

  def self.config
    @config ||= Config.new.tap do |conf|
      conf.letters_location = Rails.root.join('tmp', 'letter_opener')
      conf.auto_dark_mode = false
      conf.authentication_enabled = false
    end
  end

  def self.configure
    yield config if block_given?
    config.warn_if_basic_auth_misconfigured
  end

  def self.reset!
    @config = nil
  end
end
