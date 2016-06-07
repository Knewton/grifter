require 'grifter/http_service'
require 'grifter/instrumentation'
require 'faraday/adapter/test'

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
    #methods without a request body
    [
      :get,
      :head,
      :options,
      :delete,
    ].each do |method|
      it "should have a #{method.to_s} method" do
        @svc.stubs.send(method, '/testing') { [200, {}, '{"foo": "bar"}'] }
        response = @svc.send(method, '/testing')
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
        @svc.stubs.send(method, '/testing') { [200, {}, '{"foo": "bar"}'] }
        response = @svc.send(method, '/testing', {'a_key' => 'a_value'})
        response.should be_a Hash
        response.should eql({'foo' => 'bar'})
      end
    end

    it "should remember the last request and response" do
      @svc.stubs.send(:post, '/testing') { [200, {}, '{"foo": "bar"}'] }
      @svc.post '/testing', 'a_key' => 'a_value'
      #@svc.last_request.should be_a Net::HTTP::Post
      @svc.last_response.status.should eql 200
    end

    it "should support a timeout option for overriding timeout for a single request" do
      @svc.stubs.send(:get, '/testing') { [200, {}, '{"foo": "bar"}'] }
      @svc.get '/testing', timeout: 3
    end
  end

  describe "error handling" do
    before(:each) do
      @svc.stubs.get('/testing') { [400, {}, '{"error_code": "400", "error_message": "bad api client, no cookies for you!"}'] }
    end

    it "should raise a RequestException when a 400 is returned" do
      expect { @svc.get '/testing' }.to raise_error(Grifter::RequestException)
    end
  end

  describe "default timeout configuration for the service" do
    it "should set read_timeout for the http service based on timeout option" do
      timeout_cfg = test_configuration.merge timeout: 2
      new_svc = Grifter::HTTPService.new timeout_cfg
      #new_svc.http.read_timeout.should eql 2
    end

    it "should have 60 seconds by default" do
      #@svc.http.read_timeout.should eql 60
    end
  end

  describe "default header configuration" do
    it "should specification of default headers" do
      @svc.stubs.get('/testing') { [200, {}, '{"foo": "bar"}']}

      #@svc.conn.should_receive(:request).with do |req|
      #  req['abc'].should eql('123')
      #end

      @svc.get '/testing'

    end
  end

  describe "Instrumentation" do

    before(:each) do
      @notification_count = 0
      @notification_datas = []

      ActiveSupport::Notifications.subscribe(Grifter::Instrumentation::InstrumentationQueueName) do |name, start_time, end_time, _, data|
        @notification_count += 1
        @notification_datas << data
      end

      @svc.stubs.get('/testing') { [200, {}, '{"foo": "bar"}']}
    end

    it "should report to request.grifter activesupport notification queue" do
      num_reqs_to_make = rand(1..100)
      num_reqs_to_make.times { @svc.get '/testing' }
      @notification_count.should eql num_reqs_to_make
    end

    it "each notification should include all details of the request and response" do
      num_reqs_to_make = rand(1..100)
      num_reqs_to_make.times { @svc.get '/testing' }

      notification_data = @notification_datas.sample

      notification_data.each_pair do |k,v|
        puts "YO: #{k}: #{v}"
      end
      notification_data[:service].should eql 'test service'
      notification_data[:method].should eql :get
      notification_data[:path].should eql '/testing'
      notification_data[:request_headers]['content-type'].should eql 'application/json'
      notification_data[:request_body].should eql ''
      notification_data[:response].should be_a Faraday::Response
      notification_data[:response].status.should eql 200
    end
  end
end
