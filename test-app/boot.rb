$:.unshift Dir.pwd

require 'bundler'
Bundler.setup :default

require "tiny-rails"
require "rails"

require "action_controller/railtie"
require "sprockets/railtie"
require "action_mailer/railtie"

Bundler.require :default

class TinyRailsApp < Rails::Application
  config.consider_all_requests_local = true

  config.active_support.deprecation = :log

  config.autoload_paths << config.root

  config.middleware.delete "Rack::Lock"
  config.middleware.delete "ActionDispatch::Flash"
  config.middleware.delete "ActionDispatch::BestStandardsSupport"
  config.middleware.use Rails::Rack::LogTailer, "log/#{Rails.env}.log"

  # We need a secret token for session, cookies, etc.
  config.secret_token = "49837489qkuweoiuoqwehisuakshdjksadhaisdy78o34y138974xyqp9rmye8yrpiokeuioqwzyoiuxftoyqiuxrhm3iou1hrzmjk"

  # Enable asset pipeline
  config.assets.enabled = true
  config.assets.debug   = true
end

require 'initializers' if File.exists?('initializers.rb')

TinyRailsApp.initialize!

TinyRailsApp.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/"
  match "/favicon.ico", :to => proc {|env| [200, {}, [""]] }
end
