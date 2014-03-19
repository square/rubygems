##
# Verify signed JSON documents in The Update Framework (TUF) format

class Gem::TUF::Verifier
  def initialize keys, threshold = 1
    @keys, @threshold = keys, threshold
  end

  def verify json, now = Time.now
    signed = json['signed']
    raise ArgumentError, "no data to sign" unless signed

    expiration = Time.parse(signed['expires'])
    raise Gem::TUF::VerificationError, "document is expired" if expiration <= now

    signatures = json['signatures']
    raise ArgumentError, "no signatures present" unless signatures

    to_verify = Gem::TUF::Serialize.dump(signed)
    verified_count = 0

    signatures.each do |signature|
      key = @keys.find { |key| key.id == signature['keyid'] }
      next unless key

      signature = signature['sig']
      verified = key.verify(signature, to_verify)
      verified_count += 1 if verified
    end

    if verified_count >= @threshold
      signed
    else
      raise Gem::TUF::VerificationError, "failed to meet threshhold of valid signatures (#{verified_count} of #{@threshold})"
    end
  end
end
