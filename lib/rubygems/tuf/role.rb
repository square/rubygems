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
  end
end
