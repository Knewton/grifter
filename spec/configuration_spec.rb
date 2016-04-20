require 'grifter/configuration'

describe Grifter::Configuration do

  let(:configuration) { Class.new.extend(Grifter::Configuration) }

  let(:empty_config) { {} }

  let(:no_service_config) { { services: {} } }

  let(:single_basic_service_config) {
    {
      services: {
                  twitter: { hostname: 'twitter.com' }
                }
    }
  }

  let(:all_service_values_defined) {
    {
      services: {
        twitter: {
          hostname: 'twitter.com',
          port: 8888,
          ssl: true,
          ignore_ssl_cert: true,
          base_uri: '/api/v2',
          url: 'https://twitter.com:8888',
        }
      },
      environments: {
        qa: {
          twitter: {
            url: 'http://qa.twitter.com:1234'
          },
          aliases: [:qa_alt]
        }
      }
    }
  }

  let(:url_based_configuration) {
    {
      services: {
        fakebook: {
          url: 'https://api.fake.facebook.com:1234/v3'
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
          faraday_url: 'http://twitter.com:80',
        }}
      )
    end

    it "should allow overrides for all values" do
      config = configuration.normalize_config all_service_values_defined
      config.should eql(all_service_values_defined)
    end

    it "should allow overriding configuration based on an environment variable with the URL" do
      ENV['GRIFTER_MYAPI_URL'] = 'https://override.myapi.net:98765/baseuri'
      config = configuration.load_config_file config_file: 'spec/resources/example_with_no_grifts/example_config.yml'
      ENV['GRIFTER_MYAPI_URL'] = nil
      config[:services].should eql({
        myapi: {
          hostname: 'override.myapi.net',
          name: 'myapi',
          port: 98765,
          ssl: true,
          ignore_ssl_cert: false,
          base_uri: '/baseuri',
          faraday_url: 'https://override.myapi.net:98765',
          default_headers: { :'user-agent' => 'RSpec', :test => '0' },
        },
        myotherapi: {
          hostname: 'myotherapi.com',
          name: 'myotherapi',
          port: 80,
          ssl: false,
          ignore_ssl_cert: false,
          base_uri: '',
          faraday_url: 'http://myotherapi.com:80',
        },
      })
    end
  end

  describe "URL based configuration" do
    it "should support defining all configuration aspects via a single url" do
      config = configuration.normalize_config url_based_configuration
      config[:services].should include :fakebook
      config[:services][:fakebook].should eql({
        hostname: 'api.fake.facebook.com',
        port: 1234,
        ssl: true,
        ignore_ssl_cert: false,
        base_uri: '/v3',
        name: 'fakebook',
        faraday_url: 'https://api.fake.facebook.com:1234',
      })
    end

    it "should raise an error for a bad url" do
      bad_config = { services: { badurl: { url: 'http://has a space.com' }}}
      expect { configuration.normalize_config bad_config }.to raise_error GrifterConfigurationError
    end

    it "should support environment overrides for url" do
      config = configuration.normalize_config all_service_values_defined, environment: :qa
      config[:services].should eql({
        twitter: {
          hostname: 'qa.twitter.com',
          port: 1234,
          ssl: false,
          ignore_ssl_cert: true,
          base_uri: '',
          name: 'twitter',
          faraday_url: 'http://qa.twitter.com:1234',
        }
      })
    end

    it "should support environment overrides based on an alias to the environment" do
      config = configuration.normalize_config all_service_values_defined, environment: :qa_alt
      config[:services].should eql({
        twitter: {
          hostname: 'qa.twitter.com',
          port: 1234,
          ssl: false,
          ignore_ssl_cert: true,
          base_uri: '',
          name: 'twitter',
          faraday_url: 'http://qa.twitter.com:1234',
        }
      })
    end


  end

  describe "loading config from a file" do
    it "should allow specifying a filename" do
      config = configuration.load_config_file config_file: 'spec/resources/example_with_no_grifts/example_config.yml'
      config[:services].should eql({
        myapi: {
          hostname: 'myapi.com',
          name: 'myapi',
          port: 80,
          ssl: false,
          ignore_ssl_cert: false,
          base_uri: '',
          faraday_url: 'http://myapi.com:80',
          default_headers: { :'user-agent' => 'RSpec', :test => '0' },
        },
        myotherapi: {
          hostname: 'myotherapi.com',
          name: 'myotherapi',
          port: 80,
          ssl: false,
          ignore_ssl_cert: false,
          base_uri: '',
          faraday_url: 'http://myotherapi.com:80',
        },
      })
    end

    it "should take the filename from an environment variable if specified" do
      ENV['GRIFTER_CONFIG_FILE'] = 'spec/resources/example_with_no_grifts/example_config.yml'
      config = configuration.load_config_file
      config[:services].keys.should =~ [:myapi, :myotherapi]
      ENV['GRIFTER_CONFIG_FILE'] = nil
    end

    it "should raise a custom exception if config file does not exist" do
      #this allows the cmd line utility to give good feedback
      expect {
        configuration.load_config_file config_file: 'completely_fake_path.yml'
      }.to raise_error GrifterConfigFileMissing
    end
  end

  describe "environment based overriding" do
    it "should allow overriding configuration based on an environment name" do
      config = configuration.load_config_file config_file: 'spec/resources/example_with_no_grifts/example_config.yml',
                                              environment: :dev
      config[:services].should eql({
        myapi: {
          hostname: 'dev.myapi.com',
          name: 'myapi',
          port: 123,
          ssl: false,
          ignore_ssl_cert: false,
          base_uri: '',
          faraday_url: 'http://dev.myapi.com:123',
          default_headers: { :'user-agent' => 'RSpec test', :test => '1' },
        },
        myotherapi: {
          hostname: 'myotherapi.com',
          name: 'myotherapi',
          port: 80,
          ssl: false,
          ignore_ssl_cert: false,
          base_uri: '',
          faraday_url: 'http://myotherapi.com:80',
        },
      })

    end

    it "should allow setting environment via an environment variable" do
      ENV['GRIFTER_ENVIRONMENT'] = 'dev'
      config = configuration.load_config_file config_file: 'spec/resources/example_with_no_grifts/example_config.yml'

      config[:services][:myapi][:hostname].should eql 'dev.myapi.com'
      ENV['GRIFTER_ENVIRONMENT'] = nil
    end

    it "should allow setting environment via an environment variable with an environment alias" do
      ENV['GRIFTER_ENVIRONMENT'] = 'dev_alt'
      config = configuration.load_config_file config_file: 'spec/resources/example_with_no_grifts/example_config.yml'

      config[:services][:myapi][:hostname].should eql 'dev.myapi.com'
      ENV['GRIFTER_ENVIRONMENT'] = nil
    end

  end
end
