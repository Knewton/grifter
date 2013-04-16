Gem::Specification.new do |s|
  s.name               = "hapi"
  s.version            = "0.0.1"
  s.default_executable = "hapi"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Robert Schultheis"]
  s.date = %q{2013-04-01}
  s.description = %q{A HTTP API JSON Client}
  s.email = %q{rob@knewton.com}
  s.files = Dir['lib/**/*.rb', 'bin/hapi']
  s.executables << 'hapi'
  s.test_files = Dir["spec/**/*_spec.rb"]
  #s.homepage = %q{http://rubygems.org/gems/grifter}
  s.require_paths = ["lib"]
  #s.rubygems_version = %q{1.6.2}
  s.summary = %q{Use hapi to make your api calls happy}
  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'json'

end
