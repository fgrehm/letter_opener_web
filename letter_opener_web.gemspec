# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'letter_opener_web/version'

Gem::Specification.new do |gem|
  gem.name                  = 'letter_opener_web'
  gem.version               = LetterOpenerWeb::VERSION
  gem.authors               = ['Fabio Rehm', 'David Muto']
  gem.email                 = ['fgrehm@gmail.com', 'david.muto@gmail.com']
  gem.description           = 'Gives letter_opener an interface for browsing sent emails'
  gem.summary               = gem.description
  gem.homepage              = 'https://github.com/fgrehm/letter_opener_web'
  gem.license               = 'MIT'
  gem.required_ruby_version = '>= 2.7'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^exe/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'actionmailer', '>= 5.2', '< 8'
  gem.add_dependency 'letter_opener', '~> 1.7'
  gem.add_dependency 'railties', '>= 5.2', '< 8'
  gem.add_dependency 'rexml'

  gem.add_development_dependency 'rails', '~> 6.1', '< 8'
  gem.add_development_dependency 'rspec-rails', '~> 5.0'
  gem.add_development_dependency 'rubocop', '~> 1.22'
  gem.add_development_dependency 'rubocop-rails', '~> 2.12'
  gem.add_development_dependency 'rubocop-rspec', '~> 2.5'
  gem.add_development_dependency 'shoulda-matchers', '~> 5.0'
end
