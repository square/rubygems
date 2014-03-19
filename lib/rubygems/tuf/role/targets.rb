require 'rubygems/tuf/key'
require 'rubygems/tuf/signer'

module Gem::TUF
  module Role
    # TODO: DRY this up with Root role
    class Targets
      def self.empty(expires_in, timestamp=Time.now)
        new({
          'ts'          => timestamp.utc.to_s,
          'expires'     => (timestamp.utc + expires_in).to_s,
          'delegations' => {},
          'targets'     => {}
        })
      end

      def initialize(content)
        @target = content
        @root   = @target.fetch('delegations', {})
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

      def unwrap_role(role, content)
        # TODO: get threshold for role rather than requiring all signatures to
        # be valid.
        signer.unwrap(content, self)
      end

      def to_hash
        {'_type' => 'Targets'}.merge(@target)
      end

      def add_file(file)
        if @target['targets'][file.path]
          raise "File already exists: #{file.path}."
        end

        replace_file(file)
      end

      def replace_file(file)
        @target['targets'][file.path] = file.to_hash
      end

      def delegate_to(role_spec)
        role_spec.keys.each do |key|
          keys[key.id] = key.to_hash
        end

        delegated_roles << role_spec.metadata
      end

      def files
        @target.fetch('targets')
      end

      def keys
        @root['keys'] ||= {}
      end

      def delegated_roles
        @root['roles'] ||= []
      end

      def fetch(key_id)
        key(key_id)
      end

      def path_for(role)
        "targets/#{role}"
      end

      def delegations
        @root['roles']
      end

      private

      attr_reader :root

      def key(key_id)
        keys = root.fetch('keys', {})

        Gem::TUF::Key.new(keys.fetch(key_id))
      end

      def signer
        Gem::TUF::Signer
      end
    end
  end
end
