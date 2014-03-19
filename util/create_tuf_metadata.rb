$LOAD_PATH << File.expand_path("../../lib", __FILE__)

require 'openssl'
require 'rubygems/tuf'
require 'time'

ROLE_NAMES = %w[root targets timestamp release mirrors]
TARGET_ROLES = %w[targets/claimed targets/recently-claimed targets/unclaimed]

def make_key_pair role_name
  private_key_file = "test/rubygems/tuf/#{role_name.gsub('/', '-')}-private.pem"
  public_key_file  = "test/rubygems/tuf/#{role_name.gsub('/', '-')}-public.pem"

  if File.exists? private_key_file
    # Read the existing private key from file
    private_key = File.read(private_key_file)
    key = Gem::TUF::Key.private_key(private_key)
  else
    # Generate a new private key and write to file
    key = Gem::TUF::Key.create_key
    File.write private_key_file, key.private
  end

  # Always overwrite the public_key file in case it does not
  # match the private_key we have. This should write out the same
  # data if the public_key is already correct.
  File.write public_key_file, key.public

  key
end

def deserialize_role_key role_name
  File.read "test/rubygems/tuf/#{role_name.gsub('/', '-')}-private.pem"
end

def file_for_role(role)
  Gem::TUF::File.new("#{role}.txt", File.read("test/rubygems/tuf/#{role}.txt"))
end

def write_signed_metadata(role, metadata)
  rsa_key = deserialize_role_key(role)
  key = Gem::TUF::Key.private_key(rsa_key)
  signed_content = Gem::TUF::Signer.sign({"signed" => metadata}, key)
  File.write("test/rubygems/tuf/#{role}.txt", JSON.pretty_generate(signed_content))
end

def generate_test_root
  roles = {}
  keys = {}

  root = Gem::TUF::Role::Root.empty

  roles = ROLE_NAMES.map do |role|
    key = make_key_pair role
    Gem::TUF::Role::RoleSpec.new(role, [key])
  end

  root.add_roles(roles)

  write_signed_metadata("root", root.to_hash)
end

def generate_test_targets
  # TODO: multiple target files
  # TODO: There is a recommend value in spec
  targets = Gem::TUF::Role::Targets.empty(10000)

  TARGET_ROLES.each do |role|
    key = make_key_pair role
    role_spec = Gem::TUF::Role::RoleSpec.new(role, [key], 1, [])
    targets.delegate_to(role_spec)
  end

  write_signed_metadata("targets", targets.to_hash)
end

def generate_test_timestamp
  timestamp = Gem::TUF::Role::Timestamp.empty

  timestamp.replace file_for_role('release')

  write_signed_metadata("timestamp", timestamp.to_hash)
end

def generate_test_release
  release = Gem::TUF::Role::Release.empty

  release.replace file_for_role('root')
  release.replace file_for_role('targets')

  write_signed_metadata("release", release.to_hash)
end

def generate_test_metadata
  generate_test_root
  generate_test_targets
  generate_test_release
  generate_test_timestamp
end

generate_test_metadata
