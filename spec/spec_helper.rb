# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|

  config.order = 'random'

  # grifter cares about few environment variables, all of which start with GRIFTER_
  # so going into each test we need them cleared to avoid unexpected behavior
  # tests explicity set these env vars when needed
  config.before(:each) do
    ENV.delete_if { |env_var_name| env_var_name =~ /^GRIFTER_/ }
  end

end
