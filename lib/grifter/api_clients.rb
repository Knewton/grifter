require_relative 'http'
require_relative 'configuration'

module Grifter
  module ApiClients

    include Grifter::Configuration

    def grifter_build_client_methods
      grifter_configuration[:services].each_pair do |svc, svc_cfg|
        grifter_add_service svc, svc_cfg
      end
    end

    # add a service to grifter
    #
    # @param name [String] the name of the service
    # @param url [String] an absolute url to the api
    def grifter_add_service name, url_or_svc_cfg_hash

      svc_cfg = case url_or_svc_cfg_hash
      when String
        {'url' => url_or_svc_cfg_hash}
      when Hash
        url_or_svc_cfg_hash
      else
        raise 'invalid call to create a grifter service'
      end

      init_config
      services_config = grifter_configuration['services']
      services_config[name] = svc_cfg
      @grifter_configuration.tcfg_set 'services', services_config

      @grifter_http_clients ||= {}
      @grifter_http_clients[name] = Grifter::HTTP.new grifter_configuration['services'][name]
      define_singleton_method name.intern do
        @grifter_http_clients[name]
      end
    end


  end
end
