require 'rubygems'
require 'bundler/setup'

require 'combustion'
Bundler.require :default, :development

Combustion.initialize! :action_controller, :action_view, :sprockets, :action_mailer

run Combustion::Application
