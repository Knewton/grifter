require 'grifter'

describe Grifter do
  describe "Configuration" do
    it "should allow for initializing from a config file" do
      grifter = Grifter.new :config_file => 'spec/resources/example_config.yml'
      grifter.should respond_to(:myapi)
      grifter.myapi.name.should eql('myapi')
      grifter.services.any?{|s| s.name == 'myapi' }.should be_true

      grifter.should respond_to(:myotherapi)
      grifter.myotherapi.name.should eql('myotherapi')
      grifter.services.any?{|s| s.name == 'myotherapi' }.should be_true
    end

    it "should allow access to reading it's configuration" do
      grifter = Grifter.new :config_file => 'spec/resources/example_config.yml'
      grifter.should respond_to(:grifter_configuration)
      grifter.grifter_configuration.should be_a Hash
      grifter.grifter_configuration.keys.should =~ [:grift_globs, :authenticate, :load_from_config_file, :services, :config_file, :environments]
    end
  end

  describe "Grifter files" do
    it "should allow loading grifter files which define methods for interacting with apis" do
      grifter = Grifter.new :config_file => 'spec/resources/grifter.yml'
      grifter.should respond_to :timeline_for
    end

    describe "syntax errors" do
      it "should produce a nice stack trace if a grifter file has a syntax error" do
        expect do
          grifter = Grifter.new load_from_config_file: false,
            grift_globs: ['spec/resources/syntax_error_grifts/eval_error_grifts.rb']
        end.to raise_error NoMethodError
      end
    end
  end

  describe "Authentication" do
    it "when authenticate is invoked, it should call any method ending in grifter_authenticate" do
      grifter = Grifter.new :config_file => 'spec/resources/example_config.yml'
      grifter.define_singleton_method :test_svc_grifter_authenticate do
        true
      end
      grifter.define_singleton_method :test_svc_grifter_authenticate_substring_only do
        true
      end

      grifter.should_receive :test_svc_grifter_authenticate
      grifter.should_not_receive :test_svc_grifter_authenticate_substring_only

      grifter.grifter_authenticate_do
    end

    #TODO: test that ensures grifter_authenticate_do is called
    #      if Grifter is instantiated with :authenticate => true
  end
end
