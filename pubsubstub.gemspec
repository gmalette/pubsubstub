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

  spec.add_dependency 'sinatra'
  spec.add_dependency 'em-hiredis'

  spec.add_development_dependency "bundler", "~> 1.5.0.rc.1"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "em-rspec"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "thin"

end
