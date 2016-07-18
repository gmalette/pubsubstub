require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

namespace :spec do
  task :all do
    Dir['gemfiles/*'].reject { |p| p.end_with?('.lock') }.each do |gemfile|
      command = %(BUNDLE_GEMFILE=#{gemfile} bundle exec rspec)
      puts command
      system(command)
    end
  end
end

namespace :gemfiles do
  task :update do
    Dir['gemfiles/*'].reject { |p| p.end_with?('.lock') }.each do |gemfile|
      command = %(BUNDLE_GEMFILE=#{gemfile} bundle update)
      puts command
      system(command)
    end
  end
end
