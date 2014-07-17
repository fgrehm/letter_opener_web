# Fix for ruby 1.8.7
require 'active_support/core_ext/kernel/singleton_class'

require 'letter_opener'
require 'letter_opener_web/delivery_method'

module LetterOpenerWeb
  class Engine < ::Rails::Engine
    isolate_namespace LetterOpenerWeb

    initializer "letter_opener_web.add_delivery_method" do
      ActionMailer::Base.add_delivery_method :letter_opener_web, LetterOpenerWeb::DeliveryMethod, :location => Rails.root.join("tmp", "letter_opener")
    end

    initializer "assets" do |app|
      Rails.application.config.assets.precompile += %w(
        letter_opener_web/application.js
        letter_opener_web/application.css
        letter_opener_web/glyphicons-halflings.png
        letter_opener_web/glyphicons-halflings-white.png
        letter_opener_web/blue-dot.ico
      )
    end
  end
end
