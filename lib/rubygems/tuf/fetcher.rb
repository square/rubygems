require 'rubygems/tuf'

# TODO: Move this code in here
$LOAD_PATH.unshift(File.expand_path("~/Code/os/rubygems.org/app/models"))

require 'tuf/repository'

class HttpBucket
  def initialize(fetcher, initial_uri)
    @fetcher     = fetcher

    # Used as the remote host, scheme and port for all future requests. This is
    # kind of weird but I'm not sure a better way to pass it through.
    @initial_uri = initial_uri
  end

  def get(path, opts = {})
    # TODO: https, options
    uri = @initial_uri.dup
    uri.path = '/' + path
    @fetcher.fetch_http(uri)
  end

  def create(*)
    raise "Not supported, this is a read-only bucket."
  end
end

class Gem::TUF::Fetcher < Gem::RemoteFetcher
  def initialize(proxy)
    super
  end

  def fetch_path(uri, mtime = nil, head = false)
    # TODO: Support updating of root.txt
    # TODO: Support loading resource from JAR/JRuby?
    last_good_root = File.read('root.txt') ||
                     raise("Can't find root.txt")

    repository = Tuf::Repository.new(
      root:   JSON.parse(last_good_root),
      bucket: HttpBucket.new(self, uri)
    )

    file = repository.target(uri.path[1..-1])
    if file
      data = file.body

      # TODO: DRY up with RemoteFetcher
      if data and !head and uri.to_s =~ /gz$/
        begin
          data = Gem.gunzip data
        rescue Zlib::GzipFile::Error
          raise FetchError.new("server did not return a valid file", uri.to_s)
        end
      end

      data
    else
      raise FetchError.new("server did not return a valid file", uri.to_s)
    end
  end
end
