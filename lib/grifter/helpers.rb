require_relative '../grifter'

class Grifter
  module Helpers

    def grifter_instance
      @@grifter_instance ||= ::Grifter.new
    end
    module_function :grifter_instance

    def self.included(mod)
      def grifter
        grifter_instance
      end

      grifter_instance.singleton_methods.each do |meth|
        define_method meth do |*args, &block|
          grifter_instance.send(meth, *args, &block)
        end
      end
    end

  end
end
