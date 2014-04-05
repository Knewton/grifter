require_relative 'grifts'

module Grifter
  class << self
    include Grifter::Grifts

    def initialize
      super
    end
  end
end
Grifter.initialize
