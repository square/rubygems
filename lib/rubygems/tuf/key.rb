require 'rubygems/tuf/serialize'
require 'digest/sha2'

module Gem::TUF

  # Value object for working with TUF key hashes.
  class Key

    # Convenience methods for programatically building keys.
    def self.private_key(private)
      raise TypeError, "expecting a #{Gem::TUF::KEY_ALGORITHM}, got #{private.class}" unless private.is_a? Gem::TUF::KEY_ALGORITHM
      raise TypeError, "ZOMG! #{Gem::TUF::KEY_ALGORITHM} is a public key!!?" unless private.private?

      build("rsa", private.to_pem, private.public_key.to_pem)
    end

    def self.public_key(public)
      raise TypeError, "expecting a #{Gem::TUF::KEY_ALGORITHM}, got #{public.class}" unless public.is_a? Gem::TUF::KEY_ALGORITHM
      raise TypeError, "ZOMG! #{Gem::TUF::KEY_ALGORITHM} is a private key!!!" if public.private?

      build("rsa", "", public.to_pem)
    end

    def self.build(type, private, public)
      new Gem::TUF::Serialize.roundtrip(
        'keytype' => type,
        'keyval' => {'private' => private, 'public' => public}
      )
    end

    def initialize(key)
      @key     = key
      @public  = key.fetch('keyval').fetch('public')
      @private = key.fetch('keyval').fetch('private')
      @type    = key.fetch('keytype')
      generate_id
    end

    # TODO: Unsupported for public key
    def sign(content)
      case type
      when 'insecure'
        Digest::MD5.hexdigest(public + content)
      when 'rsa'
        rsa_key = Gem::TUF::KEY_ALGORITHM.new(private)
        rsa_key.sign(digest, content).unpack("H*")[0]
      else raise "Unknown key type: #{type}"
      end
    end

    def verify(signature, data)
      case type
      when 'insecure'
        signature == Digest::MD5.hexdigest(public + data)
      when 'rsa'
        signature_bytes = [signature].pack("H*")
        rsa_key = Gem::TUF::KEY_ALGORITHM.new(public)
        rsa_key.verify(digest, signature_bytes, data)
      else raise "Unknown key type: #{type}"
      end
    end

    def to_hash
      {
        'keytype' => type,
        'keyval' => {
          'private' => '', # Never include private key when writing out
          'public' => public,
        }
      }
    end

    attr_reader :id, :public, :private, :type

    private

    def generate_id
      json = Gem::TUF::Serialize.canonical(to_hash)
      @id = Digest::SHA256.hexdigest(json)
    end

    def digest
      @digest ||= OpenSSL::Digest.new(Gem::TUF::DIGEST_NAME)
    end
  end
end
