require_relative 'grifts'

module Grifter
  class << self
    include Grifter::Grifts

    def initialize
      super
    end

    def new options={}
      options = ActiveSupport::HashWithIndifferentAccess.new options
      grifter_instance = Class.new { include Grifter::Grifts }.new

      grifter_instance.grifter_config_file options.fetch(:config_file, 'grifter.yml')
      grifter_instance.grifter_initialize
    end
  end
end
#Grifter.initialize
