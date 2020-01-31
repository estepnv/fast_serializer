module FastSerializer
  module Utils
    def self.symbolize_keys(hash)
      res = {}
      hash.each { |key, _| res[key.to_sym] = hash[key] }
      hash
    end
  end
end
