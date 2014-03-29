# Pubsubstub

Pubsubstub is a rack middleware to add Pub/Sub

## Installation

Add this line to your application's Gemfile:

    gem 'pubsubstub'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pubsubstub

## Usage

### Rails

    match "/events", to: Pubsubstub::Application, via: :all

### Standalone

You can easily run Pubsubstub standalone by creating a `config.ru` file containing

    require 'pubsubstub'

    run Pubsubstub::Application

To start the application, run `bundle exec thin start --timeout 0 --max-conns 1024`

## Contributing

1. Fork it ( http://github.com/<my-github-username>/pubsubstub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
