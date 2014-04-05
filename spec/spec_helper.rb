# include the grifter lib folder
# This is a nice way to test a gem
require 'bundler/setup'
Bundler.setup

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
#require 'grifter'

#configure rspec basics
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true

  #setting this to false ensure if we screw up a tag, nothing will run
  # and we'll know a tag is screwed up.
  config.run_all_when_everything_filtered = false

  # removing this bit of config as it will interfere with our custom tagging scheme
  #config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  #  config.order = 'random'

  #config.include TestDataHelpers
  #

  #some tests use environment variables prefixed with GRIFTER_
  #its best to just always clear any env vars with that prefix
  config.before(:each) do
    ENV.delete_if {|k| k =~ /^GRIFTER_/ }
  end

end