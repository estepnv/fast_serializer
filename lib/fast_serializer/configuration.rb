# frozen_string_literal: true

require 'json'

module FastSerializer
  class Configuration

    RubyVer = Struct.new(:major, :feature, :fix) do

      def is_2_4_or_less
        major == 2 && feature <= 4
      end
    end

    attr_reader :coder, :ruby_ver
    attr_accessor :strict

    def initialize
      @coder = JSON
      @strict = false
      @ruby_ver = RubyVer.new(*RUBY_VERSION.split(".").map(&:to_i))
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
