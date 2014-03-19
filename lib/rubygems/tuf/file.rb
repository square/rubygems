require 'digest/sha2'

module Gem::TUF
  class File
    def self.from_body(path, body)
      new(path, body)
    end

    def self.from_metadata(path, metadata)
      FileSpec.new(path, metadata)
    end

    def initialize(path, body)
      @path   = path
      @body   = body
      @length = body.bytesize
      @hash   = Gem::TUF::HASH_ALGORITHM.hexdigest(@body)
    end

    def to_hash
      {
        'hashes' => { Gem::TUF::HASH_ALGORITHM_NAME => @hash },
        'length' => @length,
      }
    end

    def path_with_hash
      ext  = ::File.extname(path)
      dir  = ::File.dirname(path)
      base = ::File.basename(path, ext)

      ::File.join(dir, base + '.' + hash + ext)
    end

    attr_reader :path, :body, :length, :hash
  end

  class FileSpec
    attr_reader :path, :length, :hash

    def initialize(path, metadata)
      @path   = path
      @hash   = metadata.fetch('hashes').fetch(Gem::TUF::HASH_ALGORITHM_NAME)
      @length = metadata.fetch('length')
    end

    # TODO: De-dup with above
    def path_with_hash
      ext  = ::File.extname(path)
      dir  = ::File.dirname(path)
      base = ::File.basename(path, ext)

      ::File.join(dir, base + '.' + hash + ext)
    end

    def attach_body!(body)
      file = File.from_body(path, body)

      raise "Invalid length for #{path}. Expected #{length}, got #{file.length}" unless file.length == length
      raise "Invalid hash for #{path}" unless file.hash == hash

      file
    end
  end
end
