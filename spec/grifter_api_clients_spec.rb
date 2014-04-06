require 'grifter/api_clients'

describe Grifter::ApiClients do
  subject { Class.new { include Grifter::ApiClients}.new }

  describe '#grifter_add_service' do
    it "should allow specifying services through a method call" do
      subject.grifter_add_service 'mynewapi', 'http://api.my.new.io'
      subject.grifter_configuration['services'].should have_key 'mynewapi'
      subject.grifter_add_service 'myextranewapi', 'http://api.my.new.us'
      subject.grifter_configuration['services'].should have_key 'mynewapi'
      subject.grifter_configuration['services'].should have_key 'myextranewapi'
    end

    it "should raise an error if url is not absolute" do
      expect {subject.grifter_add_service 'mynewapi', 'xxx'}.to raise_error(Grifter::ConfigurationError)
    end
  end
end


