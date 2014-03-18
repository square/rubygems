require 'digest/sha2'

module Gem::TUF
  ##
  # Digest algorithm used to sign gems

  DIGEST_ALGORITHM = Digest::SHA512

  ##
  # Used internally to select the signing digest from all computed digests

  DIGEST_NAME = DIGEST_ALGORITHM.name.split("::").last.downcase

  ##
  # Algorithm for creating the key pair used to sign gems

  KEY_ALGORITHM =
    if defined?(OpenSSL::PKey) then
      OpenSSL::PKey::RSA
    end

  ##
  # Length of keys created by KEY_ALGORITHM

  KEY_LENGTH = 2048

  class VerificationError < StandardError; end
end

require 'rubygems/tuf/signer'
require 'rubygems/tuf/verifier'
require 'rubygems/tuf/root'
require 'rubygems/tuf/release'
require 'rubygems/tuf/repository'
