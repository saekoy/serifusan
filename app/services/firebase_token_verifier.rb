require 'net/http'
require 'openssl'
require 'jwt'

# Firebase が発行した ID トークン（JWT）を検証する。
# 署名検証＋宛先/発行元/期限の確認を行い、問題なければユーザー情報を返す。
# 問題があれば VerificationError を raise する。
class FirebaseTokenVerifier
  class VerificationError < StandardError; end

  PROJECT_ID = ENV.fetch('FIREBASE_PROJECT_ID', 'serifusan-237f2')
  PUBLIC_KEYS_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'.freeze
  ISSUER = "https://securetoken.google.com/#{PROJECT_ID}".freeze

  class << self
    def verify(id_token)
      new(id_token).verify
    end

    # Firebase の公開鍵（複数）。Googleが指定する有効期限までメモリキャッシュする
    def public_keys
      @public_keys ||= {}
      if @keys_expires_at.nil? || Time.current >= @keys_expires_at
        fetch_public_keys!
      end
      @public_keys
    end

    def reset_cache!
      @public_keys = {}
      @keys_expires_at = nil
    end

    private

    def fetch_public_keys!
      response = Net::HTTP.get_response(URI(PUBLIC_KEYS_URL))
      raise VerificationError, "Failed to fetch public keys (HTTP #{response.code})" unless response.is_a?(Net::HTTPSuccess)

      @public_keys = JSON.parse(response.body).transform_values do |pem|
        OpenSSL::X509::Certificate.new(pem).public_key
      end

      max_age = response['cache-control'].to_s[/max-age=(\d+)/, 1]&.to_i || 3600
      @keys_expires_at = Time.current + max_age
    end
  end

  def initialize(id_token)
    @id_token = id_token
  end

  def verify
    decoded = decode_and_verify_signature
    validate_claims(decoded)
    {
      uid:          decoded['sub'],
      email:        decoded['email'],
      display_name: decoded['name'],
      photo_url:    decoded['picture'],
      provider:     decoded.dig('firebase', 'sign_in_provider') || 'unknown'
    }
  end

  private

  def decode_and_verify_signature
    header = JWT.decode(@id_token, nil, false).last
    kid = header['kid']
    raise VerificationError, 'Missing kid in header' if kid.blank?

    public_key = self.class.public_keys[kid]
    raise VerificationError, "Unknown kid: #{kid}" if public_key.nil?

    decoded, = JWT.decode(
      @id_token, public_key, true,
      algorithm: 'RS256',
      verify_iat: true,
      verify_expiration: true
    )
    decoded
  rescue JWT::DecodeError => e
    raise VerificationError, "JWT decode error: #{e.message}"
  end

  def validate_claims(decoded)
    raise VerificationError, "Invalid audience: #{decoded['aud']}" unless decoded['aud'] == PROJECT_ID
    raise VerificationError, "Invalid issuer: #{decoded['iss']}"   unless decoded['iss'] == ISSUER
    raise VerificationError, 'Missing sub claim' if decoded['sub'].to_s.empty?
    raise VerificationError, 'auth_time in future' if decoded['auth_time'] && decoded['auth_time'] > Time.current.to_i
  end
end
