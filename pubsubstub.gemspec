# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pubsubstub/version'

Gem::Specification.new do |spec|
  spec.name          = "pubsubstub"
  spec.version       = Pubsubstub::VERSION
  spec.authors       = ["Guillaume Malette"]
  spec.email         = ["gmalette@gmail.com"]
  spec.summary       = %q{Pubsubstub is a rack middleware to add Pub/Sub}
  spec.description   = %q{Pubsubstub can be added to a rack Application or deployed standalone. It uses Redis to do the Pub/Sub}
  spec.homepage      = "https://github.com/gmalette/pubsubstub"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'sinatra', "~> 1.4"
  spec.add_dependency 'em-hiredis', "~> 0.2"
  spec.add_dependency 'redis', "~> 3.0"
  spec.add_dependency 'eventmachine', "~> 1.0"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.2"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "pry", "~> 0.9"
  spec.add_development_dependency "thin", "~> 1.6"
end
