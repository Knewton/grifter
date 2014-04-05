require 'grifter'

describe Grifter do

  it "should have configuration" do
    subject.should respond_to :grifter_configuration
    subject.grifter_configuration.should be_a Hash
  end

end
