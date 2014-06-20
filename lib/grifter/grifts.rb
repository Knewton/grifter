require_relative 'configuration'
require_relative 'api_clients'
require_relative 'grift_files'

module Grifter
  module Grifts

    include Grifter::Configuration
    include Grifter::GriftFiles
    include Grifter::ApiClients

    def initialize
      grifter_initialize
      super
    end

    def grifter_initialize
      grifter_build_client_methods
      load_grifts_using_configuration
    end

  end
end
