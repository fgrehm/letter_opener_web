# letter_opener_web

![Build Status](https://github.com/fgrehm/letter_opener_web/actions/workflows/main.yml/badge.svg)
[![Gem Version](https://badge.fury.io/rb/letter_opener_web.svg)](http://badge.fury.io/rb/letter_opener_web)
[![Code Climate](https://codeclimate.com/github/fgrehm/letter_opener_web.svg)](https://codeclimate.com/github/fgrehm/letter_opener_web)

Gives [letter_opener](https://github.com/ryanb/letter_opener) an interface for
browsing sent emails.

## Installation

First add the gem to your development environment and run the `bundle` command to install it.

```ruby
group :development do
  gem 'letter_opener_web', '~> 3.0'
end
```

## Usage

Add to your `routes.rb`:

```ruby
Your::Application.routes.draw do
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
```

And make sure you have [`:letter_opener` delivery method](https://github.com/ryanb/letter_opener#rails-setup)
configured for your app. Then visit `http://localhost:3000/letter_opener` after
sending an email and have fun.

If you are running the app from a [Vagrant](http://vagrantup.com) machine or Docker
container, you might want to skip `letter_opener`'s `launchy` calls and avoid messages
like these:

```terminal
12:33:42 web.1  | Failure in opening /vagrant/tmp/letter_opener/1358825621_ba83a22/rich.html
with options {}: Unable to find a browser command. If this is unexpected, Please rerun with
environment variable LAUNCHY_DEBUG=true or the '-d' commandline option and file a bug at
https://github.com/copiousfreetime/launchy/issues/new
```

In that case (or if you really just want to browse mails using the web interface and
don't care about opening emails automatically), you can set `:letter_opener_web` as
your delivery method on your `config/environments/development.rb`:

```ruby
config.action_mailer.delivery_method = :letter_opener_web
```

If you're using `:letter_opener_web` as your delivery method, you can change the location of
the letters by adding the following to an initializer (or in `development.rb`):

```ruby
LetterOpenerWeb.configure do |config|
  config.letters_location = Rails.root.join('your', 'new', 'path')
end
```

## Usage on pre-production environments

Some people use this gem on staging / pre-production environments to avoid having real emails
being sent out. To set that up you'll need to:

1. Move the gem out of the `development` group in your `Gemfile`
2. Set `config.action_mailer.delivery_method` on the appropriate `config/environments/<env>.rb`
3. Enable the route for the environments on your `routes.rb`.

In other words, your `Gemfile` will have:

```ruby
gem 'letter_opener_web'
```

And your `routes.rb`:

```ruby
Your::Application.routes.draw do
  # If you have a dedicated config/environments/staging.rb
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.staging?

  # If you use RAILS_ENV=production in staging environments, you'll need another
  # way to disable it in "real production"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" unless ENV["PRODUCTION_FOR_REAL"]
end
```

You might also want to have a look at the sources for the [demo](http://letter-opener-web.herokuapp.com)
available at https://github.com/fgrehm/letter_opener_web_demo.

### Usage with Amazon S3 to support multiple separated instances

If you are using this gem on Heroku and your application is not using one Dyno or your have containerized setup, the default configuration won't work as the e-mail is saved on the server. You can use S3 bucket instead.

**1. Configure AWS environment:**

* Create new non-public bucket, note the name and the region
* Create new user using IAM or use existing one for which you already have `aws_access_key_id` and `aws_secret_access_key`
* Assign proper policy to the user. Replace `your-bucket-name` with the name of the bucket you have created

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:GetObject",
          "s3:DeleteObject*"
      ],
      "Resource": "arn:aws:s3:::your-bucket-name/*"
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": [
          "s3:ListBucket"
      ],
      "Resource": "arn:aws:s3:::your-bucket-name"
    }
  ]
}
```

**2. Update gem configuration:**

Add the following configuration to the initializer (or environment files):

```ruby
LetterOpenerWeb.configure do |config|
  config.aws_access_key_id = ENV['AWS_ACCESS_KEY_ID']
  config.aws_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
  config.aws_region = ENV['AWS_REGION']
  config.aws_bucket = ENV['AWS_BUCKET']
  config.letters_location = :s3
end
```

When you send e-mail with attachment(s), the presigned link is generated to attachment that is valid for 1 week.

## Acknowledgements

Special thanks to [@alexrothenberg](https://github.com/alexrothenberg) for some
ideas on [this pull request](https://github.com/ryanb/letter_opener/pull/12) and
[@pseudomuto](https://github.com/pseudomuto) for keeping the project alive for a
few years.

## Contributing

1. Fork it and run `bin/setup`
2. Create your feature branch (`git switch -c my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
