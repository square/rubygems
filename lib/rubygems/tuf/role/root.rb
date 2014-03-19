require 'rubygems/tuf/key'
require 'rubygems/tuf/signer'

module Gem::TUF
  module Role
    # TODO: DRY this up with Targets role
    class Root
      def self.empty
        new({ 'keys' => {}, 'roles' => {}})
      end

      def initialize(content)
        @root = content
      end

      def body
        @root
      end

      def unwrap_role(role, content)
        # TODO: get threshold for role rather than requiring all signatures to be
        # valid.
        signer.unwrap(content, self)
      end

      def sign_role(role, content, *keys)
        signed = keys.inject(signer.wrap(content)) do |content, key|
          signer.sign(content, key)
        end

        # Verify that this role contains sufficent public keys to unwrap what
        # was just signed.
        unwrap_role role, signed

        signed
      end

      def add_roles(role_specs)
        role_specs.each do |role_spec|
          role_spec.keys.each do |key|
            keys[key.id] ||= key.to_hash
          end

          roles[role_spec.role] = role_spec.metadata(false)
        end
      end

      def to_hash
        {'_type' => 'Root'}.merge(@root)
      end

      def fetch(key_id)
        key(key_id)
      end

      def path_for(role)
        "#{role}.txt"
      end

      def keys
        @root['keys'] ||= {}
      end

      def roles
        @root['roles'] ||= {}
      end

      def delegations
        @root['roles']
      end

      private

      attr_reader :root

      def key(key_id)
        Gem::TUF::Key.new(keys.fetch(key_id) {
          raise "#{key_id} not found among:\n#{keys.keys.join("\n")}"
        })
      end

      def signer
        Gem::TUF::Signer
      end
    end
  end
end
