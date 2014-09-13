# letter_opener_web

[![Build Status](https://travis-ci.org/fgrehm/letter_opener_web.png?branch=master)](https://travis-ci.org/fgrehm/letter_opener_web) [![Gem Version](https://badge.fury.io/rb/letter_opener_web.png)](http://badge.fury.io/rb/letter_opener_web) [![Code Climate](https://codeclimate.com/github/fgrehm/letter_opener_web.png)](https://codeclimate.com/github/fgrehm/letter_opener_web) [![Gittip](http://img.shields.io/gittip/fgrehm.svg)](https://www.gittip.com/fgrehm/) [![Gitter chat](https://badges.gitter.im/fgrehm/letter_opener_web.png)](https://gitter.im/fgrehm/letter_opener_web)

Gives [letter_opener](https://github.com/ryanb/letter_opener) an interface for
browsing sent emails.

Check out http://letter-opener-web.herokuapp.com to see it in action.

## Installation

First add the gem to your development environment and run the `bundle` command to install it.

```ruby
gem 'letter_opener_web', '~> 1.2.0', :group => :development
```

## Usage

Add to your routes.rb:

```ruby
Your::Application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
```

And make sure you have [`:letter_opener` delivery method](https://github.com/ryanb/letter_opener#rails-setup)
configured for your app. Then visit `http://localhost:3000/letter_opener` after
sending an email and have fun.

If you are running the app from a [Vagrant](http://vagrantup.com) machine, you
might want to skip `letter_opener`'s `launchy` calls and avoid messages like these:

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

# If you receive errors from REXML parsing your HTML emails, you can use the following additional setting
config.use_link_adjustment = false
```

## Usage on Heroku

Some people use this gem on staging environments on Heroku and to set that up
is just a matter of moving the gem out of the `development` group and enabling
the route for all environments on your `routes.rb`.

In order words, your `Gemfile` will have:

```ruby
gem 'letter_opener_web', '~> 1.2.0'
```

And your `routes.rb`:

```ruby
Your::Application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
```

You might also want to have a look at the sources for the [demo](http://letter-opener-web.herokuapp.com)
available at https://github.com/fgrehm/letter_opener_web_demo.

## Acknowledgements

Special thanks to [@alexrothenberg](https://github.com/alexrothenberg) for some
ideas on [this pull request](https://github.com/ryanb/letter_opener/pull/12).


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
