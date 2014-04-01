# Pubsubstub

[![Build Status](https://travis-ci.org/gmalette/pubsubstub.svg?branch=master)](https://travis-ci.org/gmalette/pubsubstub)

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

    # The `as: :events` is optional, but will generate a named route for events_path
    mount Pubsubstub::Application.new, at: "/events", as: :events

You can also cherry-pick actions. For example, if you don't want to publish through HTTP:

    mount Pubsubstub::StreamAction.new, at: "/events", as: :events

This will allow you to mount a publish action in the admin, or leave it out completely.

### Authentication

Need authentication? No problem! Load a Rack middleware in front of Pubsubstub to do the job!

    mount UserRequiredMiddleware.new(Pubsubstub::StreamAction.new), at: "/events", as: :events

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
