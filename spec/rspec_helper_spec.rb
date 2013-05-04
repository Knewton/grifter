require 'hapi'
require 'hapi/helpers'

describe Hapi::Helpers do
  describe "including" do
    it "should be includable" do
      mod = Module.new do
        ENV['HAPI_CONFIG_FILE'] = 'spec/resources/hapi.yml'
        include Hapi::Helpers
      end

      cla = Class.new do
        extend mod
      end

      cla.should respond_to :hapi
      cla.hapi.should be_a Hapi

      p cla.hapi.should respond_to :timeline_for
    end
  end
end
