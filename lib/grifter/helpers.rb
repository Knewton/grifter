require_relative 'log'

class Grifter
  module Helpers
    def self.included(mod)
      Log.debug "initializing helpers in #{mod}"
      def grifter
        @_grifter ||= Grifter.new
      end
    end
  end
end
