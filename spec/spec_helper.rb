# include the grifter lib folder
# This is a nice way to test a gem
require 'bundler/setup'
Bundler.setup

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'rspec'
#require 'grifter'


module TestConstants
  FullExampleFile = File.expand_path('../examples/full/grifter.yml', __FILE__)
  FullExampleDir = File.dirname FullExampleFile

  SingleGriftFile = File.expand_path('../examples/simple_grifts/grifts.rb', __FILE__)
  GriftFileWithARequire = File.expand_path('../examples/simple_grifts/grift_file_with_a_require.rb', __FILE__)
  GriftFileWithState = File.expand_path('../examples/simple_grifts/grift_file_with_state.rb', __FILE__)

  SampleGriftGlob = 'spec/examples/sample_grift_collection/**/*_grifts.rb'
end
include TestConstants

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
  config.order = 'random'

  #some tests use environment variables prefixed with GRIFTER_
  #its best to just always clear any env vars with that prefix
  config.before(:each) do
    ENV.delete_if {|k| k =~ /^GRIFTER_/ }
  end

end
