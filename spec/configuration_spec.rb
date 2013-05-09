require 'grifter/configuration'

describe Grifter::Configuration do

  let(:configuration) { Class.new.extend(Grifter::Configuration) }

  let(:empty_config) { {} }

  let (:no_service_config) { { services: {} } }

  let (:single_basic_service_config) {
    {
      services: {
                  twitter: { hostname: 'twitter.com' }
                }
    }
  }

  let (:all_service_values_defined) {
    {
      services: {
        twitter: {
          hostname: 'twitter.com',
          port: 8888,
          ssl: true,
          ignore_ssl_cert: true,
          base_uri: '/api/v2',
        }
      }
    }
  }

  describe "Service configuration normalization" do
    it "should require a services block" do
      expect { configuration.normalize_config empty_config }.to raise_error GrifterConfigurationError
    end

    it "should require at least one service in service block" do
      expect { configuration.normalize_config no_service_config }.to raise_error GrifterConfigurationError
    end

    it "should default ssl, ssl_certificate_ignore, and port" do
      config = configuration.normalize_config single_basic_service_config
      config[:services].should eql({
        twitter: {
          hostname: 'twitter.com',
          port: 80,
          ssl: false,
          ignore_ssl_cert: false,
          base_uri: '',
          name: 'twitter',
        }}
      )
    end

    it "should allow overrides for all values" do
      config = configuration.normalize_config all_service_values_defined
      config.should eql(all_service_values_defined)
    end
  end

  describe "loading config from a file" do
    it "should allow specifying a filename" do
      config = configuration.load_config_file config_file: 'spec/resources/example_config.yml'
      config[:services].should eql({
        myapi: {
          hostname: 'myapi.com',
          name: 'myapi',
          port: 80,
          ssl: false,
          ignore_ssl_cert: false,
          base_uri: '',
        },
        myotherapi: {
          hostname: 'myotherapi.com',
          name: 'myotherapi',
          port: 80,
          ssl: false,
          ignore_ssl_cert: false,
          base_uri: '',
        },
      })
    end

    it "should take the filename from an environment variable if specified" do
      ENV['GRIFTER_CONFIG_FILE'] = 'spec/resources/example_config.yml'
      config = configuration.load_config_file
      config[:services].keys.should =~ [:myapi, :myotherapi]
      ENV['GRIFTER_CONFIG_FILE'] = nil
    end
  end

  describe "environment based overriding" do
    it "should allow overriding configuration based on an environment name" do
      config = configuration.load_config_file config_file: 'spec/resources/example_config.yml',
                                              environment: :dev
      config[:services].should eql({
        myapi: {
          hostname: 'dev.myapi.com',
          name: 'myapi',
          port: 123,
          ssl: false,
          ignore_ssl_cert: false,
          base_uri: '',
        },
        myotherapi: {
          hostname: 'myotherapi.com',
          name: 'myotherapi',
          port: 80,
          ssl: false,
          ignore_ssl_cert: false,
          base_uri: '',
        },
      })

    end

    it "should allow setting environment via an environment variable" do
      ENV['GRIFTER_ENVIRONMENT'] = 'dev'
      config = configuration.load_config_file config_file: 'spec/resources/example_config.yml'

      config[:services][:myapi][:hostname].should eql 'dev.myapi.com'
      ENV['GRIFTER_ENVIRONMENT'] = nil

    end
  end
end
