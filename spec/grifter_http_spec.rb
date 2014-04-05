require 'grifter/http'
require 'faraday/adapter/test'

describe Grifter::HTTP do

  let(:test_configuration) do
    {
      name: 'test service',
      hostname: 'totallyfakedomainthatcouldnotpossiblyexist.com',
      port: 80,
      ssl: false,
      ignore_ssl_certificate: false,
    }
  end

  subject { described_class.new test_configuration }

  describe "http methods" do
    #methods without a request body
    [
      :get,
      :head,
      :options,
      :delete,
    ].each do |method|
      it "should have a #{method.to_s} method" do
        subject.stubs.send(method, '/testing') { [200, {}, '{"foo": "bar"}'] }
        response = subject.send(method, '/testing')
        response.should be_a Hash
        response.should eql({'foo' => 'bar'})
      end
    end

    #methods with a json request body
    [
      :put,
      :post,
      :patch,
    ].each do |method|
      it "should have a #{method.to_s} method" do
        subject.stubs.send(method, '/testing') { [200, {}, '{"foo": "bar"}'] }
        response = subject.send(method, '/testing', {'a_key' => 'a_value'})
        response.should be_a Hash
        response.should eql({'foo' => 'bar'})
      end
    end

    it "should remember the last request and response" do
        subject.stubs.send(:post, '/testing') { [200, {}, '{"foo": "bar"}'] }
        subject.post '/testing', 'a_key' => 'a_value'
        #subject.last_request.should be_a Net::HTTP::Post
        subject.last_response.status.should eql 200
    end

    it "should support a timeout option for overriding timeout for a single request" do
      subject.stubs.send(:get, '/testing') { [200, {}, '{"foo": "bar"}'] }
      subject.get '/testing', timeout: 3
    end
  end

  describe "error handling" do
    before(:each) do
      subject.stubs.get('/testing') { [400, {}, '{"error_code": "400", "error_message": "bad api client, no cookies for you!"}'] }
    end

    it "should raise a RequestException when a 400 is returned" do
      expect { subject.get '/testing' }.to raise_error(Grifter::RequestException)
    end
  end

  describe "default timeout configuration for the service" do
    it "should set read_timeout for the http service based on timeout option" do
      timeout_cfg = test_configuration.merge timeout: 2
      new_svc = Grifter::HTTP.new timeout_cfg
      #new_svc.http.read_timeout.should eql 2
    end

  end

  describe "default header configuration" do
    it "should specification of default headers" do
      subject.stubs.get('/testing') { [200, {}, '{"foo": "bar"}']}

      #subject.conn.should_receive(:request).with do |req|
      #  req['abc'].should eql('123')
      #end

      subject.get '/testing'

    end
  end
end
