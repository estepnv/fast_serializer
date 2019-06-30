module FastSerializer
  class Configuration
    attr_accessor :coder

    def initialize
      @coder = JSON
    end
  end

  class << self
    def config
      @_config ||= Configuration.new
    end

    def configure(&block)
      block.call(config) if !block.nil?
    end
  end
end