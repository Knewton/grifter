require 'grifter'

describe Grifter do

  it "should have configuration" do
    subject.should respond_to :grifter_configuration
    subject.grifter_configuration.should be_a Hash
  end

  context "a service name yourapi is configured" do
    before(:each) do
      subject.grifter_service 'yourapi', 'https://yourapi.com'
    end

    it "should get a class method for service yourapi" do
      subject.build_services
      subject.should respond_to :yourapi
      subject.yourapi.should be_a Grifter::HTTP
      subject.yourapi.should respond_to :get
    end
  end

end
