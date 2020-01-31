# frozen_string_literal: true

require 'json'

module FastSerializer
  class Configuration
    attr_reader :coder
    attr_accessor :strict

    def initialize
      @coder = JSON
      @strict = false
    end

    def coder=(obj)
      if obj.respond_to?(:dump) && obj.respond_to?(:load)
        @coder = obj
      else
        raise ArgumentError, "must respond to #load and #dump methods"
      end
    end
  end

  class << self
    def config
      @_config ||= Configuration.new
    end

    def configure(&block)
      block&.call(config)
    end
  end
end
