require 'net/http'

require_relative 'json_helpers'
require_relative 'log'

class Hapi
  class HTTPService

    include Hapi::JsonHelpers

    def initialize config

      @config = config
      @name = config[:name]
      @base_uri = config[:base_uri]

      Log.debug "Configuring service '#{@name}' with:\n\t#{@config.inspect}"

      @http = Net::HTTP.new(@config[:hostname], @config[:port])
      @http.use_ssl = @config[:ssl]
      @http.verify_mode = OpenSSL::SSL::VERIFY_NONE if @config[:ignore_ssl_cert]

      @headers = {
        'accept' => 'application/json',
        'content-type' => 'application/json',
      }
    end

    #allow stubbing http if we are testing
    attr_reader :http if defined?(RSpec)

    attr_reader :headers, :name

    RequestLogSeperator = '-'*40
    def do_request req
      Log.debug RequestLogSeperator
      Log.debug "#{req.class} #{req.path}"
      Log.debug "HEADERS: #{req.to_hash}"
      Log.debug "BODY:\n#{req.body}" if req.request_body_permitted?
      response = @http.request(req)
      Log.debug "RESPONSE CODE: #{response.code}"
      Log.debug "RESPONSE HEADERS: #{response.to_hash}"
      Log.debug "RESPONSE BODY:\n#{jsonify response.body}\n"

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
      do_request req
    end

    def head path, options={}
      req = Net::HTTP::Head.new(*req_args(path, options))
      do_request req
    end

    def delete path, options={}
      req = Net::HTTP::Delete.new(*req_args(path, options))
      do_request req
    end

    def post path, obj, options={}
      req = Net::HTTP::Post.new(*req_args(path, options))
      req.body = jsonify(obj)
      do_request req
    end

    def put path, obj, options={}
      req = Net::HTTP::Put.new(*req_args(path, options))
      req.body = jsonify(obj)
      do_request req
    end

    def post_form path, params, options={}
      request_obj = Net::HTTP::Post.new(*req_args(path, options))
      request_obj.set_form_data params
      request_obj.basic_auth(options[:username], options[:password]) if options[:username]
      do_request request_obj
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

