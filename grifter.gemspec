# Generated by juwelier
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Juwelier::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: grifter 0.5.0 ruby lib

Gem::Specification.new do |s|
  s.name = "grifter".freeze
  s.version = "0.5.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0".freeze) if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib".freeze]
  s.authors = ["Robert Schultheis".freeze]
  s.date = "2020-11-04"
  s.description = "convention based approach to interfacing with an HTTP JSON API.".freeze
  s.email = "rob@knewton.com".freeze
  s.executables = ["grift".freeze]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "Readme.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "Readme.md",
    "bin/grift",
    "grifter.gemspec",
    "lib/grifter.rb",
    "lib/grifter/blankslate.rb",
    "lib/grifter/configuration.rb",
    "lib/grifter/helpers.rb",
    "lib/grifter/http_service.rb",
    "lib/grifter/instrumentation.rb",
    "lib/grifter/json_helpers.rb",
    "lib/grifter/log.rb"
  ]
  s.homepage = "http://github.com/knewton/grifter".freeze
  s.licenses = ["MIT".freeze]
  s.rubygems_version = "3.1.2".freeze
  s.summary = "Make calls to HTTP JSON APIs with ease and confidence".freeze

  if s.respond_to? :specification_version then
    s.specification_version = 4
  end

  if s.respond_to? :add_runtime_dependency then
    s.add_runtime_dependency(%q<faraday>.freeze, ["~> 1"])
    s.add_runtime_dependency(%q<json>.freeze, [">= 0"])
    s.add_runtime_dependency(%q<typhoeus>.freeze, ["~> 1"])
    s.add_runtime_dependency(%q<activesupport>.freeze, ["~> 4"])
    s.add_development_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_development_dependency(%q<pry>.freeze, [">= 0"])
    s.add_development_dependency(%q<awesome_print>.freeze, [">= 0"])
    s.add_development_dependency(%q<juwelier>.freeze, ["~> 2"])
  else
    s.add_dependency(%q<faraday>.freeze, ["~> 1"])
    s.add_dependency(%q<json>.freeze, [">= 0"])
    s.add_dependency(%q<typhoeus>.freeze, ["~> 1"])
    s.add_dependency(%q<activesupport>.freeze, ["~> 4"])
    s.add_dependency(%q<rspec>.freeze, [">= 0"])
    s.add_dependency(%q<pry>.freeze, [">= 0"])
    s.add_dependency(%q<awesome_print>.freeze, [">= 0"])
    s.add_dependency(%q<juwelier>.freeze, ["~> 2"])
  end
end

