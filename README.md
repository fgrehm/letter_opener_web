# LetterOpenerWeb

Gives [letter_opener](https://github.com/ryanb/letter_opener) an interface for
browsing sent emails.

## Installation

First add the gem to your development environment and run the `bundle` command to install it.

    gem 'letter_opener_web', :group => :development

## Usage

Add to your routes.rb:

```ruby
Your::Application.routes.draw do
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
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
