require 'grifter/configuration'

describe Grifter::Configuration do
  subject { Class.new { include Grifter::Configuration }.new }

  #these specs involve changing around the working directory
  #to pick up tcfg.yml / tcfg.secret.yml by default
  before(:each) do
    @orig_working_dir = Dir.pwd
  end

  after(:each) do
    Dir.chdir @orig_working_dir
  end

  context "grifter.yml is not in current working directory" do
    it "should respond to grifter_configuration" do
      subject.grifter_configuration.should == {}
    end
  end

  context "grifter.yml is in current working directory" do
    FullExampleDir = File.expand_path('../examples/full', __FILE__)
    before(:each) do
      Dir.chdir FullExampleDir
    end

    it "should have configuration from grifter.yml" do
      subject.grifter_configuration.should_not == {}
      subject.grifter_configuration.should have_key 'services'
    end
  end
end
