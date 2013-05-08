require 'grifter/http_service'

describe Grifter::HTTPService do

  let(:test_configuration) do
    {
      name: 'test service',
      hostname: 'totallyfakedomainthatcouldnotpossiblyexist.com',
      port: 80,
      ssl: false,
      ignore_ssl_certificate: false,
    }
  end

  before(:each) do
    @svc = Grifter::HTTPService.new test_configuration
  end

  describe "http methods" do
    before(:each) do
      response = Net::HTTPOK.new('1.1', 200, "stub response body")
      response.stub(:body).and_return '{"foo": "bar"}'
      @svc.http.stub!(:request).and_return(response)
    end

    #methods without a request body
    [
      :get,
      :head,
      :delete,
    ].each do |method|
      it "should have a #{method.to_s} method" do
        @svc.send(method, '/testing').should be_a Hash
      end
    end

    #methods with a json request body
    [
      :put,
      :post,
    ].each do |method|
      it "should have a #{method.to_s} method" do
        @svc.send(method, '/testing', {'a_key' => 'a_value'}).should be_a Hash
      end
    end

    it "should remember the last request and response" do
        @svc.post '/testing', 'a_key' => 'a_value'
        @svc.last_request.should be_a Net::HTTP::Post
        @svc.last_response.should be_a Net::HTTPOK
    end
  end

  describe "error handling" do
    before(:each) do
      response = Net::HTTPBadRequest.new('1.1', 400, "stuff not sure what it does")
      response.stub(:body).and_return '{"error_code": "400", "error_message": "bad api client, no cookies for you!"}'
      @svc.http.stub!(:request).and_return(response)
    end

    it "should raise a RequestException when a 400 is returned" do
      expect { @svc.get '/testing' }.to raise_error(Grifter::RequestException)
    end
  end
end
