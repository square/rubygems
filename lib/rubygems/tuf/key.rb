require 'rubygems/tuf/serialize'

module Gem::TUF
  ##
  # Digest algorithm used for TUF signatures

  DIGEST_ALGORITHM =
    if defined?(OpenSSL::Digest) then
      OpenSSL::Digest::SHA1
    end

  ##
  # Signature Algorithm used for TUF signatures

  KEY_ALGORITHM =
    if defined?(OpenSSL::PKey) then
      OpenSSL::PKey::RSA
    end

  ##
  # Length of keys created by KEY_ALGORITHM

  KEY_LENGTH = 2048

  # Value object for working with TUF key hashes.
  class Key

    # Convenience methods for programatically building keys.
    def self.private_key(private, algorithm = KEY_ALGORITHM)
      key = algorithm.new(private)
      raise TypeError, "ZOMG! #{algorithm} is a public key!!?" unless key.private?

      build("rsa", key.to_pem, key.public_key.to_pem)
    end

    def self.public_key(public, algorithm = KEY_ALGORITHM)
      key = algorithm.new(public)
      raise TypeError, "ZOMG! #{algorithm} is a private key!!!" if key.private?

      build("rsa", "", key.to_pem)
    end

    def self.build(type, private, public)
      new({
        'keytype' => type,
        'keyval' => {
          'private' => private,
          'public' => public
        }
      })
    end

    ##
    # Creates a new key pair of the specified +length+ and +algorithm+.  The
    # default is a 2048 bit RSA key.

    def self.create_key length = KEY_LENGTH, algorithm = KEY_ALGORITHM
      private_key(algorithm.new(length))
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
        rsa_key = KEY_ALGORITHM.new(private)
        rsa_key.sign(DIGEST_ALGORITHM.new, content).unpack("H*")[0]
      else raise "Unknown key type: #{type}"
      end
    end

    def verify(signature, data)
      case type
      when 'insecure'
        signature == Digest::MD5.hexdigest(public + data)
      when 'rsa'
        signature_bytes = [signature].pack("H*")
        rsa_key = KEY_ALGORITHM.new(public)
        rsa_key.verify(DIGEST_ALGORITHM.new, signature_bytes, data)
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
      json = Gem::TUF::Serialize.dump(to_hash)
      @id = Gem::TUF::HASH_ALGORITHM.hexdigest(json)
    end
  end
end
