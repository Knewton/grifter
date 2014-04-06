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
    it "should return a blank configuration, with an empty services hash" do
      subject.grifter_configuration.should == {'services' => {}}
    end
  end

  it "should get configuration fron config file if given a valid config file" do
    subject.grifter_config_file FullExampleFile
    subject.grifter_configuration['services']['myapi']['url'].should eql 'https://my.api.com'
  end

  it "should raise an error if given a non-existent config file" do
    expect { subject.grifter_config_file 'xxx.yml' }.to raise_error(TCFG::NoSuchConfigFileError)
  end

  context "grifter.yml is in current working directory" do

    before(:each) do
      Dir.chdir FullExampleDir
    end

    it "should have configuration from grifter.yml" do
      subject.grifter_configuration.should_not == {}
      subject.grifter_configuration.should have_key 'services'
    end

    it "should not include the grifter_environments configuration" do
      subject.grifter_configuration.should_not have_key 'environments'
      subject.grifter_configuration.should_not have_key 'grifter_environments'
    end

    it "should use 'GRIFTER_ENVIRONMENT' to load configuration for a given environment" do
      ENV['GRIFTER_ENVIRONMENT'] = 'qa'
      subject.grifter_configuration['services']['myapi']['url'].should eql 'http://qa.my.api.com'
      subject.grifter_configuration['services']['myotherapi']['url'].should eql 'https://my.other.api.net'
    end

    it "should throw a TCFG error if environment is not specified" do
      ENV['GRIFTER_ENVIRONMENT'] = 'qax'
      expect { subject.grifter_configuration }.to raise_error(TCFG::NoSuchEnvironmentError)
    end

    it "should allow forcing a url for a service through environment variable overrides" do
      ENV['GRIFTER_services-myapi-url'] = 'http://override.com'
      subject.grifter_configuration['services']['myapi']['url'].should == 'http://override.com'
    end
  end


  describe "resolving configuration" do

    before(:each) do
      subject.grifter_config_file FullExampleFile
    end

    it "each service should get resolved configuration" do
      services = subject.grifter_configuration['services']
      services.values.each do |scfg|
        scfg.should have_key 'name'
        scfg.should have_key 'base_uri'
        scfg.should have_key 'faraday_url'
        expect {URI.parse scfg['faraday_url']}.to_not raise_error
      end
    end

  end
end
