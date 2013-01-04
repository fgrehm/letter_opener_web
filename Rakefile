#!/usr/bin/env rake

desc 'Print out all defined routes in match order, with names. Target specific controller with CONTROLLER=x.'
task :routes do
  require 'combustion'
  Bundler.require :default, :development

  Combustion.initialize! :action_controller, :action_view, :sprockets, :action_mailer

  all_routes = LetterOpenerWeb::Engine.routes.routes

  require 'rails/application/route_inspector'
  inspector = Rails::Application::RouteInspector.new
  puts inspector.format(all_routes, ENV['CONTROLLER']).join "\n"
end

begin
  require 'rdoc/task'
rescue LoadError
  require 'rdoc/rdoc'
  require 'rake/rdoctask'
  RDoc::Task = Rake::RDocTask
end

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'LetterOpenerWeb'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'bundler/gem_tasks'

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :default => :spec
rescue LoadError; end
