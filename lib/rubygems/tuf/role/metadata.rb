require 'json'

require 'rubygems/tuf/file'

module Gem::TUF
  module Role
    class NullBucket
      def get(*_); raise "Remote operations not available" end
      def create(*_); raise "Remote operations not available" end
    end

    class Metadata

      def self.build(expires_in, metadata, now = Time.now)
        new({
          "ts"       => now.utc.to_s,
          "expires"  => (now.utc + expires_in).to_s,
          "meta"     => build_metadata(metadata)
        }, NullBucket.new)
      end

      def self.empty(bucket = NullBucket.new)
        new({'meta' => {}}, bucket)
      end

      def initialize(source, bucket)
        @source = source
        @role_metadata = source['meta']
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

      def to_hash
        {
          '_type'   => type,
          'ts'      => source.fetch('ts'),
          'expires' => source.fetch('expires'),
          'meta'    => role_metadata,
          'version' => 2
        }
      end

      def type
        self.class.name.split('::').last
      end

      attr_reader :source, :role_metadata, :bucket

      protected

      def self.build_metadata(metadata)
        metadata.map do |path, content|
          [path,  { 'hashes' => hash(content), 'length' => content.length }]
        end.to_h
      end

      def self.hash(content)
        {
          Gem::TUF::HASH_ALGORITHM_NAME =>
            Gem::TUF::HASH_ALGORITHM.hexdigest(content)
        }
      end
    end

    class Timestamp < Metadata
    end

    class Release < Metadata
    end
  end
end
