require 'grifter'
require 'grifter/helpers'

describe Grifter::Helpers do
  describe "including" do
    it "should be includable" do
      mod = Module.new do
        ENV['GRIFTER_CONFIG_FILE'] = 'spec/resources/grifter.yml'
        include Grifter::Helpers
      end

      cla = Class.new do
        extend mod
      end

      cla.should respond_to :grifter
      cla.grifter.should be_a Grifter

      p cla.grifter.should respond_to :timeline_for
    end
  end
end
