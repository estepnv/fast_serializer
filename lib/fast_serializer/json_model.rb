# frozen_string_literal: true

module FastSerializer
  module JsonModel
  end
end

require 'fast_serializer/json_model/node'
require 'fast_serializer/json_model/object'
require 'fast_serializer/json_model/attribute'
require 'fast_serializer/json_model/relationship'
require 'fast_serializer/json_model/has_one_relationship'
require 'fast_serializer/json_model/has_many_relationship'
require 'fast_serializer/json_model/array'

puts "Loaded"