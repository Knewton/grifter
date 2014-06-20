require 'uri'

require 'tcfg/tcfg_base'

module Grifter
  module Configuration

    DEFAULT_CONFIG_FILE = 'grifter.yml'
    DEFAULT_GRIFT_GLOBS = ['*_grifts/*_grifts.rb']

    def grifter_configuration
      init_config
      @grifter_configuration.tcfg
    end

    def grifter_config_file filename
      @grifter_config_file = filename
      init_config
    end

    private

    def grifter_config_file_path
      if @grifter_config_file 
        File.expand_path @grifter_config_file
      elsif File.exist? DEFAULT_CONFIG_FILE
        File.expand_path DEFAULT_CONFIG_FILE
      else
        nil
      end
    end

    #ensure the configuration is resolved and ready to use
    #
    # @param force_refresh [Boolean] if false and configuration has been initialized it will not be re-initialized
    def init_config
      if !@grifter_configuration
        @grifter_configuration = TCFG::Base.new

        #build up some default configuration
        @grifter_configuration.tcfg_set 'services', {}
        @grifter_configuration.tcfg_set 'grift_globs', DEFAULT_GRIFT_GLOBS

        @grifter_configuration.tcfg_set_env_var_prefix 'GRIFTER_'
      end

      if grifter_config_file_path
        #if a config file was specified, we assume it exists
        @grifter_configuration.tcfg_config_file grifter_config_file_path
      else
        Log.warn "No configuration file specified or found. Make a grift.yml file and point grifter at it."
      end
      @grifter_configuration.tcfg_set 'grifter_config_file', grifter_config_file_path

      normalize_services_config @grifter_configuration

      nil
    end

    def normalize_services_config cfg
      services = cfg['services']
      services.each_pair do |svc, svc_cfg|
        #add the name
        svc_cfg['name'] = svc

        unless svc_cfg.has_key? :url
          raise ConfigurationError.new "url for service '#{svc_cfg['name']}' is not defined"
        end

        unless svc_cfg['url'] =~ URI::ABS_URI
          raise ConfigurationError.new "url for service '#{svc_cfg['name']}' is not a proper absolute URL: #{svc_cfg['url']}"
        end

        parsed = URI.parse svc_cfg['url']

        svc_cfg['base_uri'] ||= parsed.path

        svc_cfg['faraday_url'] = "#{parsed.scheme}://#{parsed.host}:#{parsed.port}"
      end

      cfg.tcfg_set 'services', services
    end

  end

  class ConfigurationError < StandardError;end
end
