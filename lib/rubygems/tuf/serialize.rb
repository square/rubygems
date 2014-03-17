require 'rubygems/util/canonical_json'

module Gem::TUF
  class Serialize
    def self.canonical(document)
      CanonicalJSON.dump(document)
    end

    def self.roundtrip(document)
      JSON.parse(canonical(document))
    end
  end
end
