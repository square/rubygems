require 'digest/sha2'

module Gem::TUF
  ##
  # Hash algorithm used to generate target hashes

  HASH_ALGORITHM = Digest::SHA256

  ##
  # Name of the Hash algorithm used

  HASH_ALGORITHM_NAME = HASH_ALGORITHM.name.split('::').last.downcase

  class VerificationError < StandardError; end
end

require 'rubygems/tuf/signer'
require 'rubygems/tuf/verifier'
require 'rubygems/tuf/root'
require 'rubygems/tuf/release'
require 'rubygems/tuf/repository'
