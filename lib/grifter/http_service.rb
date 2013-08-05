require 'net/http'

require_relative 'json_helpers'
require_relative 'log'

class Grifter
  class HTTPService

    include Grifter::JsonHelpers

    def initialize config

      @config = config
      @name = config[:name]
      @base_uri = config[:base_uri]

      Log.debug "Configuring service '#{@name}' with:\n\t#{@config.inspect}"

      @http = Net::HTTP.new(@config[:hostname], @config[:port])
      @http.use_ssl = @config[:ssl]
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @config[:ignore_ssl_cert]
      @http.read_timeout = @config[:timeout] if @config[:timeout]
      p @config

      @headers = {
        'accept' => 'application/json',
        'content-type' => 'application/json',
      }
      if @config[:default_headers]
        Log.debug "Default headers configured: " + @config[:default_headers].inspect
        @config[:default_headers].each_pair do |k, v|
          @headers[k.to_s] = v.to_s
        end
      end
    end

    #allow stubbing http if we are testing
    attr_reader :http if defined?(RSpec)

    attr_reader :headers, :name, :config

    #this is useful for testing apis, and other times
    #you want to interrogate the http details of a response
    attr_reader :last_request, :last_response

    RequestLogSeperator = '-'*40

    # do_request performs the actual request, and does associated logging
    # options can include:
    # - :timeout, which specifies num secs the request should timeout in
    #   (this turns out to be kind of annoying to implement)
    def do_request req, options={}
      Log.debug RequestLogSeperator
      Log.debug "#{req.class} #{req.path}"
      Log.debug "HEADERS: #{req.to_hash}"
      Log.debug "BODY:\n#{req.body}" if req.request_body_permitted?

      if options.has_key? :timeout
        cur_timeout = @http.read_timeout
        Log.debug "Overriding timeout to: #{options[:timeout]}"
        @http.read_timeout = options[:timeout]
      end

      response = @http.request(req)

      if cur_timeout
        @http.read_timeout = cur_timeout
      end

      Log.debug "RESPONSE CODE: #{response.code}"
      Log.debug "RESPONSE HEADERS: #{response.to_hash}"
      Log.debug "RESPONSE BODY:\n#{jsonify response.body}\n"

      @last_request = req
      @last_response = response

      raise RequestException.new(req, response) unless response.kind_of? Net::HTTPSuccess

      objectify response.body
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
      if options[:additional_headers]
        @headers.merge options[:additional_headers]
      elsif options[:headers]
        options[:headers]
      else
        @headers
      end
    end

    def req_args path, options
      [make_path(path, options[:base_uri]), make_headers(options)]
    end

    def get path, options={}
      req = Net::HTTP::Get.new(*req_args(path, options))
      do_request req, options
    end

    def head path, options={}
      req = Net::HTTP::Head.new(*req_args(path, options))
      do_request req, options
    end

    def options path, options={}
      req = Net::HTTP::Options.new(*req_args(path, options))
      do_request req, options
    end

    def delete path, options={}
      req = Net::HTTP::Delete.new(*req_args(path, options))
      do_request req, options
    end

    def post path, obj, options={}
      req = Net::HTTP::Post.new(*req_args(path, options))
      req.body = jsonify(obj)
      do_request req, options
    end

    def put path, obj, options={}
      req = Net::HTTP::Put.new(*req_args(path, options))
      req.body = jsonify(obj)
      do_request req, options
    end

    def patch path, obj, options={}
      req = Net::HTTP::Patch.new(*req_args(path, options))
      req.body = jsonify(obj)
      do_request req, options
    end

    def post_form path, params, options={}
      request_obj = Net::HTTP::Post.new(*req_args(path, options))
      request_obj.set_form_data params
      do_request request_obj, options
    end
  end

  class RequestException < Exception
    def initialize(request, response)
      @request, @response = request, response
    end

    #this makes good info show up in rspec reports
    def to_s
      "#{self.class}\nResponseCode: #{@response.code}\nResponseBody:\n#{@response.body}"
    end

    #shortcut methods
    def code
      @response.code
    end

    def body
      @response.body
    end
  end
end

