require 'tcfg/tcfg_base'

module Grifter
  module Configuration

    DEFAULT_CONFIG_FILE = 'grifter.yml'

    def grifter_configuration
      init_config
      @grifter_configuration.tcfg
    end

    def config_file filename
      @grifter_config_file
      init_config true
    end

    private

    #ensure the configuration is resolved and ready to use
    #
    # @param force_refresh [Boolean] if false and configuration has been initialized it will not be re-initialized
    def init_config force_refresh=false
      if !@grifter_configuration or force_refresh
        cfg = TCFG::Base.new

        #if a config file was specified, we assume it exists
        if @grifter_config_file
          cfg.tcfg_config_file @grifter_config_file

        #if a config file was not specific, it is optional that it exist
        elsif File.exist? DEFAULT_CONFIG_FILE
          cfg.tcfg_config_file DEFAULT_CONFIG_FILE
        end

        @grifter_configuration = cfg
      end
      nil
    end

  end
end
