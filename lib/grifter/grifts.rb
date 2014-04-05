require_relative 'configuration'
require_relative 'http'

module Grifter
  module Grifts
    include Grifter::Configuration

    def initialize
      build_services
      super
    end

    def build_services
      @grifter_http_clients ||= {}
      grifter_configuration[:services].each_pair do |svc, svc_cfg|
        @grifter_http_clients[svc] = Grifter::HTTP.new svc_cfg
        define_singleton_method svc.intern do
          @grifter_http_clients[svc]
        end
      end
    end

  end
end
