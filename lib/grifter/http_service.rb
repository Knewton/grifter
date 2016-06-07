require 'faraday'
require 'typhoeus'
require 'typhoeus/adapters/faraday' #https://github.com/typhoeus/typhoeus/issues/226#issuecomment-9919517
require 'active_support/notifications'
require 'securerandom'

require_relative 'json_helpers'
require_relative 'log'

class Grifter
  class HTTPService

    include Grifter::Log
    include Grifter::JsonHelpers

    def initialize config

      @config = config
      @name = config[:name]
      @base_uri = config[:base_uri]
      @log_headers = config.fetch(:log_headers, true)
      @log_bodies = config.fetch(:log_bodies, true)

      logger.debug "Configuring service '#{@name}' with:\n\t#{@config.inspect}"

      #@conn = Net::HTTP.new(@config[:hostname], @config[:port])
      #@conn.use_ssl = @config[:ssl]
      @conn = Faraday.new @config[:faraday_url] do |conn_builder|
        #do our own logging
        #conn_builder.response logger: logger
        #conn_builder.adapter  Faraday.default_adapter  # make requests with Net::HTTP
        conn_builder.adapter  @config.fetch(:adapter, :typhoeus).intern
        conn_builder.ssl[:verify] = false if @config[:ignore_ssl_cert]

        #defaulting this to flat adapter avoids issues when duplicating parameters
        conn_builder.options[:params_encoder] = Faraday.const_get(@config.fetch(:params_encoder, 'FlatParamsEncoder'))

        #this nonsense dont work?!  https://github.com/lostisland/faraday_middleware/issues/76
        #conn_builder.use :instrumentation
      end

      @headers = {
        'accept' => 'application/json',
        'content-type' => 'application/json',
      }
      if @config[:default_headers]
        logger.debug "Default headers configured: " + @config[:default_headers].inspect
        @config[:default_headers].each_pair do |k, v|
          @headers[k.to_s] = v.to_s
        end
      end
      @default_timeout = @config.fetch(:timeout, 10)
      logger.info "Initialized grifter service '#{@name}'"
    end

    def stubs &blk
      stubs = Faraday::Adapter::Test::Stubs.new
      @conn = Faraday.new @config[:faraday_url] do |conn_builder|
        conn_builder.adapter :test, stubs
      end
      stubs
    end

    #allow stubbing http if we are testing
    attr_reader :http if defined?(RSpec)
    attr_reader :name, :config, :conn
    attr_accessor :headers  #allows for doing some fancy stuff in threading

    #this is useful for testing apis, and other times
    #you want to interrogate the http details of a response
    attr_reader :last_request, :last_response

    RequestLogSeperator = '-'*40

    # do_request performs the actual request, and does associated logging
    # options can include:
    # - :timeout, which specifies num secs the request should timeout in
    #   (this turns out to be kind of annoying to implement)
    def do_request method, path, obj=nil, options={}

      #grifter clients pass in path possibly including query params.
      #Faraday needs the query and path seperately.
      parsed = URI.parse make_path(path)
      #faraday needs the request params as a hash.
      #this turns out to be non-trivial
      query_hash = if parsed.query
                     cgi_hash = CGI.parse(parsed.query)
                     #make to account for one param having multiple values
                     cgi_hash.inject({}) { |h,(k,v)| h[k] = v[1] ? v : v.first; h }
                   else
                     nil
                   end

      req_headers = make_headers(options)

      body = if options[:form]
        URI.encode_www_form obj
      else
        jsonify(obj)
      end

      #log the request
      logger.debug [
        "Doing request: #{@name}: #{method.to_s.upcase} #{path}",
        @log_headers ? ["Request Headers:",
        req_headers.map{ |k, v| "#{k}: #{v.inspect}" }] : nil,
        @log_bodies ? ["Request Body:", body] : nil,
      ].flatten.compact.join("\n")

      #doing it this way avoids problem with OPTIONS method: https://github.com/lostisland/faraday/issues/305
      response = nil
      metrics_obj = { method: method, service: @name, path: path, request_body: body, request_headers: req_headers }
      ActiveSupport::Notifications.instrument(Grifter::Instrumentation::InstrumentationQueueName, metrics_obj) do
        response = @conn.run_request(method, nil, nil, nil) do |req|
          req.path = parsed.path
          req.params = metrics_obj[:params] = query_hash if query_hash

          req.headers = req_headers
          req.body = body
          req.options[:timeout] = options.fetch(:timeout, @default_timeout)
        end
        metrics_obj[:response] = response
      end

      logger.info "Request status: (#{response.status}) #{@name}: #{method.to_s.upcase} #{path}"
      #@last_request = req
      @last_response = response

      response_obj = objectify response.body
      if response.headers['content-type'] =~ /json/
        logger.debug [
          "Response Details:",
          @log_headers ? ["Response Headers:",
                          response.headers.map { |k, v| "#{k}: #{v.inspect}" }] : nil,
          @log_bodies ? [ "Response Body:", jsonify(response_obj)] : nil,
          ''
        ].flatten.compact.join("\n")
      end

      raise RequestException.new(nil, response) unless response.status >= 200 and response.status < 300

      return response_obj
    end

    def in_parallel &blk
      @conn.headers = @headers
      @conn.in_parallel &blk
    end

    #add base uri to request
    def make_path path_suffix, base_uri=nil
      base_uri_to_use = base_uri ? base_uri : @base_uri
      if base_uri_to_use
        base_uri_to_use + path_suffix
      else
        path_suffix
      end
    end

    def make_headers options
      headers = if options[:additional_headers]
        @headers.merge options[:additional_headers]
      elsif options[:headers]
        options[:headers]
      else
        @headers.clone
      end
      headers['content-type'] = 'application/x-www-form-urlencoded' if options[:form]
      headers
    end

    def req_args path, options
      [make_path(path, options[:base_uri]), make_headers(options)]
    end

    def get path, options={}
      do_request :get, path, nil, options
    end

    def head path, options={}
      do_request :head, path, nil, options
    end

    def options path, options={}
      do_request :options, path, nil, options
    end

    def delete path, options={}
      do_request :delete, path, nil, options
    end

    def post path, obj, options={}
      do_request :post, path, obj, options
    end

    def put path, obj, options={}
      do_request :put, path, obj, options
    end

    def patch path, obj, options={}
      do_request :patch, path, obj, options
    end

    def post_form path, params, options={}
      do_request :post, path, params, options.merge(form: true)
      #request_obj = Net::HTTP::Post.new(*req_args(path, options))
      #request_obj.set_form_data params
      #do_request request_obj, options
    end
  end

  class RequestException < Exception
    def initialize(request, response)
      @request, @response = request, response
    end

    #this makes good info show up in rspec reports
    def to_s
      "#{self.class}\nResponseCode: #{self.code}\nResponseBody:\n#{self.body}"
    end

    #shortcut methods
    def code
      @response.status
    end

    def body
      @response.body
    end
  end
end

