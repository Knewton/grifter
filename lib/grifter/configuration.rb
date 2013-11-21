require 'yaml'
require 'uri'

require_relative 'log'

class Grifter
  module Configuration
    def recursive_symbolize hash
      hash.inject({}) do |h, (k,v)|
        h[k.intern] = case v
                      when Hash
                        recursive_symbolize v
                      else
                        v
                      end
        h
      end
    end

    def get_service_config_from_url url
      return {} if url.nil?
      unless url =~ URI::ABS_URI
        raise GrifterConfigurationError.new "url is not a proper aboslute URL: #{url}"
      end
      parsed = URI.parse url
      #make the url faraday is configured with
      {
        :hostname => parsed.host,
        :port => parsed.port,
        :base_uri => parsed.path,
        :ssl => (parsed.scheme == 'https'),
      }
    end

    def load_config_file options={}
      options = {
        config_file: ENV['GRIFTER_CONFIG_FILE'] ? ENV['GRIFTER_CONFIG_FILE'] : 'grifter.yml',
        environment: ENV['GRIFTER_ENVIRONMENT'],
      }.merge(options)
      Grifter::Log.debug "Loading config file '#{options[:config_file]}'"
      unless File.exist?(options[:config_file])
        raise GrifterConfigFileMissing.new "No such config file: '#{options[:config_file]}'"
      end
      hash = YAML.load_file(options[:config_file])
      symbolized = recursive_symbolize(hash)
      normalize_config(symbolized, options)
    end

    #this method ensure the config hash has everything we need to instantiate the service objects
    def normalize_config config, options={}
      unless ((config.is_a? Hash) &&
              (config.has_key? :services) &&
              (config[:services].is_a? Hash) &&
              (config[:services].length > 0))
        raise GrifterConfigurationError.new ":services block not found in configuration"
      end

      #fill out services block entirely for each service
      config[:services].each_pair do |service_name, service_config|
        service_config[:name] = service_name.to_s

        #check for a url configuration option. This option will trump any others that may be set
        service_config.merge!(get_service_config_from_url(service_config.delete(:url)))

        #default everything that is not defined
        service_config.merge!({
          ssl: false,
          ignore_ssl_cert: false,
          base_uri: '',
          port: (service_config[:ssl] == true ? 443 : 80),
        }.merge(service_config))
      end

      #merge any environment overrides into the service block
      if options[:environment]
        config[:environment] = options[:environment].to_sym
        unless config[:environments] && config[:environments][config[:environment]]
          raise GrifterConfigurationError.new "No such environment specified in config: '#{config[:environment]}'"
        end

        config[:environments][config[:environment]].each_pair do |service_name, service_overrides|
          service_overrides.merge!(get_service_config_from_url(service_overrides.delete(:url)))
          config[:services][service_name].merge! service_overrides
        end
      else
        config[:environment] = :undefined
      end

      #merge any overrides provided via a GRIFTER_<svc name>_URL environment variable
      config[:services].each_pair do |service_name, service_config|
        env_var_name = "GRIFTER_#{service_config[:name].upcase}_URL"
        if ENV[env_var_name]
          Log.warn "Environment variable #{env_var_name} is defined, using it to override configuration"
          service_config.merge!(get_service_config_from_url(ENV[env_var_name]))
        end
      end

      #add in the faraday url as the final thing after figuring everything else out
      config[:services].each_pair do |service_name, service_config|
        #set the url we'll use to start faraday
        service_config[:faraday_url] = "#{service_config[:ssl] ? 'https':'http'}://#{service_config[:hostname]}:#{service_config[:port].to_s}"
      end

      #join the grift globs with the relative path to config file
      if config[:grift_globs] && options[:config_file]
        config_file_dir = File.dirname options[:config_file]
        config[:grift_globs].map! {|glob| config_file_dir + '/' + glob.sub(/^\//,'')}
      end

      return config
    end
  end
end

class GrifterConfigurationError < Exception
end

class GrifterConfigFileMissing < Exception
end
