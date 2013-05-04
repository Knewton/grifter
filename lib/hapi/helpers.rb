require_relative 'log'

class Hapi
  module Helpers
    def self.included(mod)
      Log.debug "initializing helpers in #{mod}"
      def hapi
        @_hapi ||= Hapi.new
      end
    end
  end
end
