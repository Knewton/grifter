require 'hapi'

describe Hapi do
  describe "Configuration" do
    it "should allow for initializing from a config file" do
      hapi = Hapi.new :config_file => 'spec/resources/example_config.yml'
      hapi.should respond_to(:myapi)
      hapi.myapi.name.should eql('myapi')
      hapi.services.any?{|s| s.name == 'myapi' }.should be_true

      hapi.should respond_to(:myotherapi)
      hapi.myotherapi.name.should eql('myotherapi')
      hapi.services.any?{|s| s.name == 'myotherapi' }.should be_true
    end
  end

  describe "Hapi files" do
    it "should allow loading hapi files which define methods for interacting with apis" do
      hapi = Hapi.new :config_file => 'example/hapi.yml'
      hapi.should respond_to :timeline_for
    end
  end
end
