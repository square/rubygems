require 'json'

require 'rubygems/tuf/file'

module Gem::TUF
  module Role
    class NullBucket
      def get(*_); raise "Remote operations not available" end
      def create(*_); raise "Remote operations not available" end
    end

    class Metadata
      DEFAULT_EXPIRY = 86400 # 1 day

      def self.empty(expires_in = DEFAULT_EXPIRY, now = Time.now, bucket = NullBucket.new)
        new({
              "ts"      => now.utc.to_s,
              "expires" => (now.utc + expires_in).to_s,
            }, bucket)
      end

      def initialize(source, bucket)
        @source = source
        @bucket = bucket
      end

      def fetch_role(role, parent)
        path = "metadata/" + role + ".txt"

        metadata = role_metadata.fetch(path) {
          raise "Could not find #{path} in: #{role_metadata.keys.sort.join("\n")}"
        }

        filespec = ::Gem::TUF::File.from_metadata(path, role_metadata[path])

        data = bucket.get(filespec.path_with_hash)

        signed_file = filespec.attach_body!(data)

        parent.unwrap_role(role, JSON.parse(signed_file.body))
      end

      def replace(file)
        role_metadata[file.path] = file.to_hash
      end

      def role_metadata
        source['meta'] ||= {}
      end

      def to_hash
        {
          '_type' => type,
          'version' => 2
        }.merge(source)
      end

      def type
        self.class.name.split('::').last
      end

      attr_reader :source, :bucket
    end

    class Timestamp < Metadata
    end

    class Release < Metadata
    end
  end
end
