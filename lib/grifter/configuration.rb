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
                      when Array # this only handles list of strings, which is good enough
                        v.map do |item|
                          item.to_sym
                        end
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
        config_file: ENV.fetch('GRIFTER_CONFIG_FILE', 'grifter.yml'),
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

        unless config[:environments]
          raise GrifterConfigurationError.new "You specified a grifter environment, but there is no environments section in the grifter configuration"
        end

        requested_environment_name = options[:environment].to_sym
        if config[:environments].has_key? requested_environment_name
          # the environment was literally specified
          env_config = config[:environments][options[:environment].to_sym]
          config[:environment] = options[:environment].to_sym
        else
          # the environment may be an alias
          config[:environments].each_pair do |env_name, env_overrides|
            if env_overrides[:aliases] and
              env_overrides[:aliases].include? requested_environment_name
              env_config = env_overrides
              config[:environment] = env_name
              break
            end
          end
        end

        if env_config.nil? || config[:environment].nil?
          raise GrifterConfigurationError.new "No such environment or environment alias specified in config: '#{requested_environment_name.to_s}'"
        end

        env_config.delete :aliases

        env_config.each_pair do |service_name, service_overrides|
          service_overrides.merge!(get_service_config_from_url(service_overrides.delete(:url)))
          config[:services][service_name].merge! service_overrides
        end

        # force the grifter environment variable to be the environment
        # in some cases grifts may include other ruby code that needs to know
        # the environment.  It may be inconvenient to include Grifter::Helpers
        # and use grifter_configuration to access that info
        # Therefore, we force set this env var, so anything included in a grift
        # can access the environment here if needed
        ENV['GRIFTER_ENVIRONMENT']= config[:environment].to_s
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

      #setup the grift globs, and this seems more sloppy than it should be
      glob_base_dir = options[:config_file] ? File.dirname(options[:config_file]) : Dir.pwd
      glob_base_dir = File.expand_path(glob_base_dir)
      config[:grift_globs] ||= options[:grift_globs]
      if config[:grift_globs]
        config[:grift_globs].map! {|glob| glob_base_dir + '/' + glob.sub(/^\//,'')}
      end

      return config
    end
  end
end

class GrifterConfigurationError < Exception
end

class GrifterConfigFileMissing < Exception
end
