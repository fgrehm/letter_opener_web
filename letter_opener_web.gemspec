# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'letter_opener_web/version'

Gem::Specification.new do |gem|
  gem.name          = 'letter_opener_web'
  gem.version       = LetterOpenerWeb::VERSION
  gem.authors       = ['Fabio Rehm']
  gem.email         = ['fgrehm@gmail.com']
  gem.description   = 'Gives letter_opener an interface for browsing sent emails'
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/fgrehm/letter_opener_web'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^exe/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'actionmailer', '>= 3.2'
  gem.add_dependency 'letter_opener', '~> 1.0'
  gem.add_dependency 'railties', '>= 3.2'

  gem.add_development_dependency 'rails', '~> 4.2.0'
  gem.add_development_dependency 'rspec-rails', '~> 3.0'
  gem.add_development_dependency 'rubocop', '~> 0.47'
  gem.add_development_dependency 'shoulda-matchers', '~> 2.5'
end
