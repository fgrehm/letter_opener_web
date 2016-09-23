require "letter_opener_web/engine"
require 'rexml/document'
require 'letter_opener_web/configuration'

module LetterOpenerWeb
  class << self

    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def config
      yield(configuration)
    end
  end
end
