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

```ruby
# The `as: :events` is optional, but will generate a named route for events_path
mount Pubsubstub::Application.new, at: "/events", as: :events
```

You can also cherry-pick actions. For example, if you don't want to publish through HTTP:

```ruby
mount Pubsubstub::StreamAction.new, at: "/events", as: :events
```

This will allow you to mount a publish action in the admin, or leave it out completely.

### Authentication

Need authentication? No problem! Load a Rack middleware in front of Pubsubstub to do the job!

```ruby
mount UserRequiredMiddleware.new(Pubsubstub::StreamAction.new), at: "/events", as: :events
```

### Standalone

You can easily run Pubsubstub standalone by creating a `config.ru` file containing

```ruby
require 'pubsubstub'

run Pubsubstub::Application
```

### Sending an event

```ruby
Pubsubstub.publish("user.#{user.id}", user.to_json, name: "user.update")
```

To start the application, run `bundle exec puma config.ru`

### HTTP Server

It is heavilly recommended to deploy Pubsubstub with `puma >= 3.4.0`. As of April 2016, it is the only ruby server that properly handle persistent connections.

Other servers like thin will either require you to set a connection timeout otherwise you won't be able to shutdown the server properly.

See the [/example/puma_config.rb](example puma config) for how to configure puma properly.

## Contributing

1. Fork it ( http://github.com/<my-github-username>/pubsubstub/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
