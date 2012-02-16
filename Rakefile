#! /usr/bin/env ruby
require 'rake'

task :default => :test

task :test do
  Dir.chdir 'test'

  sh 'rspec client_spec.rb --color --format doc'
  sh 'rspec server_spec.rb --color --format doc'
end
