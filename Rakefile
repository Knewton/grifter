# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "grifter"
  gem.homepage = "http://github.com/knewton/grifter"
  gem.license = "MIT"
  gem.summary = %Q{Make calls to HTTP JSON APIs with ease and confidence}
  gem.description = %Q{convention based approach to interfacing with an HTTP JSON API.}
  gem.email = "rob@knewton.com"
  gem.authors = ["Robert Schultheis"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "grifter #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
