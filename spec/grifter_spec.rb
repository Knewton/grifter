require 'grifter'

describe Grifter do

  before(:each) do
    Grifter.grifter_initialize
  end

  it "should have configuration" do
    subject.should respond_to :grifter_configuration
    subject.grifter_configuration.should be_a Hash
  end

  context "a service name yourapi is configured" do
    before(:each) do
      subject.grifter_add_service 'yourapi', 'https://yourapi.com'
    end

    it "should get a class method for service yourapi" do
      subject.grifter_build_client_methods
      subject.should respond_to :yourapi
      subject.yourapi.should be_a Grifter::HTTP
      subject.yourapi.should respond_to :get
    end
  end

  context "a grift file is given" do

    before(:each) do
      subject.grifter_load_grift_file SingleGriftFile
    end

    it "should have a method named gmethod" do
      Grifter.should respond_to :gmethod
      Grifter.gmethod.should == 'gmethod returned this'
    end

  end

  context "initializing from the working directory" do
    before(:each) do
      @orig_working_dir = Dir.pwd
      Dir.chdir FullExampleDir
      Grifter.grifter_initialize
    end

    after(:each) do
      Dir.chdir @orig_working_dir
    end

    it "should get services from the working directory" do
      Grifter.should respond_to :myapi
    end

    it "should get grift methods" do
      Grifter.should respond_to :a_grift_method
      Grifter.a_grift_method('x').should eql 'return value'
    end
  end

  context "initializing from a config file not in working directory" do
    before(:each) do
      Grifter.grifter_config_file FullExampleFile
      Grifter.grifter_initialize
    end

    it "should respond to services" do
      Grifter.should respond_to :myapi
    end

    it "should get grift methods" do
      Grifter.should respond_to :a_grift_method
      Grifter.a_grift_method('x').should eql 'return value'
    end
  end
end
