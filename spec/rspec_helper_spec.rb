require 'grifter'
require 'grifter/helpers'

Grifter::Helpers.module_eval do
  @@grifter_instance = nil
end

describe Grifter::Helpers do
  describe "including" do
    it "should be includable" do
      mod = Module.new do
        ENV['GRIFTER_CONFIG_FILE'] = 'spec/resources/example_with_grifts/grifter.yml'
        include Grifter::Helpers
      end

      cla = Class.new do
        extend mod
      end

      cla.should respond_to :grifter

      #should return the grifter instance if requested
      cla.grifter.should be_a Grifter
      cla.grifter.should respond_to :timeline_for

      #but better, all grift methods are just available as is
      cla.should respond_to :timeline_for

      #the raw services should be available
      cla.should respond_to :twitter
      cla.twitter.should respond_to :get
    end
  end
end
