require 'pp'

require 'rubygems/tuf/role/metadata'
require 'rubygems/tuf/role/targets'
require 'rubygems/tuf/role/root'

module Gem::TUF
  module Role
    def from_hash(content)
      case content['_type']
      when 'Root'      then Gem::TUF::Role::Root
      when 'Targets'   then Gem::TUF::Role::Targets
      when 'Release'   then Gem::TUF::Role::Release
      when 'Timestamp' then Gem::TUF::Role::Timestamp
      else raise("Unknown role: #{content.pretty_inspect}")
      end.new(content)
    end
    module_function :from_hash

    class RoleSpec
      def initialize(role, keys, threshold=1, paths=nil)
        @role = role
        @keys = keys
        @threshold = threshold
        @paths = paths
      end

      def metadata(include_role_name=false)
        result = { "keyids" => keyids, "threshold" => @threshold }
        result["paths"] = @paths unless @paths.nil?
        result["name"] = @role if include_role_name
        result
      end

      def keyids
        @keys.map { |key| key.id }
      end

      attr_reader :keys, :threshold, :role, :paths
    end
  end
end
