require 'json'

class Gem::TUF::Release
  attr_reader :targets

  def initialize root, release_txt
    parsed = JSON.parse release_txt
    @release = root.verify(:release, parsed)
    @targets = @release["meta"]["targets.txt"]
  end

  def should_update_root? current_root_txt
    @release["meta"]["root.txt"]["hashes"].any? do |type, expected_digest|
      expected_digest != current_digest(type, current_root_txt)
    end
  end

  protected

  def current_digest(type, current_root_txt)
    case type
    when Gem::TUF::HASH_ALGORITHM_NAME
     Gem::TUF::HASH_ALGORITHM.hexdigest(current_root_txt)
    else
     raise UnsupportedDigest
    end
  end
end
