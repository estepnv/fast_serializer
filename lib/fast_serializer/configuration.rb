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
      unless obj.respond_to?(:dump) && obj.respond_to?(:load)
        raise ArgumentError, 'must respond to #load and #dump methods'
      end

      @coder = obj
    end
  end

  class << self
    def config
      @config ||= Configuration.new
    end

    def configure(&block)
      block&.call(config)
    end
  end
end
