# frozen_string_literal: true

module FastSerializer
  module Utils
    def self.symbolize_keys(hash)
      res = {}
      hash.each { |key, value| res[key.to_sym] = value }
      hash
    end

    def self.ref_merge(hash_a, hash_b)
      hash_b.each do |key, value|
        hash_a[key] = value
      end
    end
  end
end
