
module Gem::TUF
  ##
  # Serialize Ruby objects to canonical JSON document format specified by
  # The Update Framework (TUF)
  class Serialize
    ##
    # Constructs a serialized representation of the +data+
    # (a basic, possibly nested, Ruby object) in the format specified by TUF.
    #
    # This format is currently specified as
    # [Canonical JSON](http://tools.ietf.org/html/draft-staykov-hu-json-canonical-form-00).

    def self.dump(data)
      canonical_json(data)
    end

    private

    # shamelessly copied from
    # https://github.com/tent/tent-canonical-json-ruby/blob/master/lib/tent-canonical-json.rb
    def self.canonical_json(data)
      case data
      when Hash
        string = data.keys.sort.map do |key|
          "#{key.to_s.inspect.gsub("\\n", "\n")}:#{canonical_json data[key]}"
        end.join(",")
        "{#{string}}"
      when Array
        json = data.map { |i|
          canonical_json(i)
        }.join(",")
        "[#{json}]"
      when Fixnum
        data
      when String, TrueClass, FalseClass
        data.to_s.inspect
      when NilClass
        "null"
      else
        raise TypeError
      end
    end
  end
end
