require 'grifter/grift_files'

describe Grifter::GriftFiles do
  subject { Class.new { include Grifter::GriftFiles }.new }

  describe '#grifter_load_grift_file' do
    it "should instantiate instance methods on a class including '#{described_class}'" do
      subject.grifter_load_grift_file SingleGriftFile
      subject.should respond_to :gmethod
      subject.gmethod.should == 'gmethod returned this'
    end

    it "should raise an exception if given a non-existent grift file" do
      expect {subject.grifter_load_grift_file SingleGriftFile+'x' }.to raise_error(Grifter::GrifterNoSuchGriftFile)
    end

    it "should load grift files so that their directory is in the LOAD_PATH" do
      #load a grift file that requires another file in it's directory
      subject.grifter_load_grift_file GriftFileWithARequire
      subject.get_that_contstant.should == 'testing is using is testing is using'
    end
  end

  describe "#grifter_load_grift_glob" do
    it "should load all the grift files in a directory" do
      subject.grifter_load_grift_glob SampleGriftGlob
      [:my_location, :weather_for, :my_weather, :kelvin_to_celcius, :my_temperature].each do |grift_method|
        subject.should respond_to grift_method
      end
    end
  end

  describe "loading grift files from configuration" do
    before(:each) do
      @orig_working_dir = Dir.pwd
    end

    after(:each) do
      Dir.chdir @orig_working_dir
    end

    it "should load the grift files based on configuration from the working directory" do
      Dir.chdir FullExampleDir
      subject.load_grifts_using_configuration
      subject.should respond_to :a_grift_method
      subject.a_grift_method('1').should eql 'return value'
    end

    it "should load the grift files based on the config file location even if its not in working directory" do
      subject.grifter_config_file FullExampleFile
      subject.load_grifts_using_configuration
      subject.should respond_to :a_grift_method
      subject.a_grift_method('1').should eql 'return value'
    end



  end

  describe "managing state in grifts" do

    #it would be nice if this worked... why dont it??
    it "should allow flat lexical scoping within a grift", :wip do
      subject.grifter_load_grift_file GriftFileWithState
      subject.get_current_state.should eql 1
      subject.increment_state
      subject.get_current_state.should eql 2
    end

    it "should allow grifts to make and use instance variables" do
      subject.grifter_load_grift_file GriftFileWithState
      subject.get_instance_var.should eql 100
      subject.increment_instance_var
      subject.get_instance_var.should eql 200
    end

  end

end
