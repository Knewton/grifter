require_relative 'grifts'

module Grifter
  class << self
    include Grifter::Grifts
  end
end
