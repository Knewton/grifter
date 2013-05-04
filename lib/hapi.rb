require_relative 'hapi/http_service'
require_relative 'hapi/configuration'
require_relative 'hapi/log'
require_relative 'hapi/blankslate'

class Hapi
  include Hapi::Configuration

  DefaultConfigOptions = {
    #TODO: service_config: nil,
    hapi_globs: ['*_hapis/**/*_hapis.rb'],
    authenticate: false,
  }
  def initialize options={}
    options = DefaultConfigOptions.merge(options)

    @config = options.merge load_config_file(options)

    #setup the services
    @services = []
    @config[:services].each_pair do |service_name, service_config|
      service = HTTPService.new(service_config)
      define_singleton_method service_name.intern do
        service
      end
      @services << service
    end

    #setup the helpers if any
    if @config[:helper_globs]
      @config[:helper_globs].each do |glob|
        Dir[glob].each do |helper_file|
          load_helper_file helper_file
        end
      end
    end

    #setup the hapi methods if any
    if @config[:hapi_globs]
      @config[:hapi_globs].each do |glob|
        Dir[glob].each do |hapi_file|
          load_hapi_file hapi_file
        end
      end
    end

    if @config[:authenticate]
      self.hapi_authenticate_do
    end
  end

  attr_reader :services

  def load_hapi_file filename
    Log.debug "Loading extension file '#{filename}'"
    code = IO.read(filename)
    anon_mod = Module.new
    #by evaling in a anonymous module, we protect this class's namespace
    anon_mod.class_eval(code)
    self.extend anon_mod

  end
  alias :load_helper_file :load_hapi_file

  def run_script_file filename
    Log.info "Running data script '#{filename}'"
    raise "No such file '#{filename}'" unless File.exist? filename
    script = IO.read(filename)
    #by running in a anonymous class, we protect this class's namespace
    anon_class = BlankSlate.new(self)
    anon_class.instance_eval(script)
  end

  #calls all methods that end with hapi_authenticate
  def hapi_authenticate_do
    auth_methods = self.singleton_methods.select { |m| m =~ /hapi_authenticate$/ }
    auth_methods.each do |m|
      Log.debug "Executing a hapi_authentication on method: #{m}"
      self.send(m)
    end
  end
end
