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
      def initialize(keys, threshold=1, name=nil, paths=nil)
        @name = name
        @keys = keys
        @threshold = threshold
        @paths = paths
      end

      def metadata
        result = { "keyids" => keyids, "threshold" => @threshold }
        result["paths"] = @paths unless @paths.nil?
        result["name"] = @name unless @name.nil?
        result
      end

      def keyids
        @keys.map { |key| key.id }
      end

      attr_reader :keys, :threshold, :name, :paths
    end
  end
end
