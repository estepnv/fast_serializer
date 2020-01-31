# frozen_string_literal: true

require 'fast_serializer/version'
require 'fast_serializer/utils'
require 'fast_serializer/configuration'
require 'fast_serializer/json_model'
require 'fast_serializer/schema'
require 'fast_serializer/schema/mixin'

module FastSerializer
  class Error < StandardError; end
end
