# LetterOpenerWeb

Gives [letter_opener](https://github.com/ryanb/letter_opener) an interface for
browsing sent emails.

## Installation

First add the gem to your development environment and run the `bundle` command to install it.

    gem 'letter_opener_web', '1.0.0.rc1', :group => :development

## Usage

Add to your routes.rb:

```ruby
Your::Application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
```

If you are using [Vagrant](http://vagrantup.com), you might want to skip
`letter_opener`'s `launchy` calls and avoid messages like these:

```terminal
12:33:42 web.1  | Failure in opening /vagrant/tmp/letter_opener/1358825621_ba83a22/rich.html
with options {}: Unable to find a browser command. If this is unexpected, Please rerun with
environment variable LAUNCHY_DEBUG=true or the '-d' commandline option and file a bug at
https://github.com/copiousfreetime/launchy/issues/new
```

In that case (or if you just want to browse mails using the web interface), you
can set `:letter_opener_web` as your delivery method on your
`config/environments/development.rb`:

```ruby
  config.action_mailer.delivery_method = :letter_opener_web

  # If not everyone on the team is using vagrant
  config.action_mailer.delivery_method = ENV['USER'] == 'vagrant' ? :letter_opener_web : :letter_opener
```

## Acknowledgements

Special thanks to [@alexrothenberg](https://github.com/alexrothenberg) for some
ideas on [this pull request](https://github.com/ryanb/letter_opener/pull/12).

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
