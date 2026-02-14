class FirebaseTokenVerifier
  CERTS_URL = "https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com"

  class VerificationError < StandardError; end

  def initialize(token)
    @token = token
    @project_id = Rails.application.credentials.dig(:firebase, :project_id)
  end

  def call
    payload, = JWT.decode(@token, nil, true, decode_options) do |header|
      cert = fetch_certificates[header["kid"]]
      raise VerificationError, "Invalid kid" unless cert
      OpenSSL::X509::Certificate.new(cert).public_key
    end

    payload
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError,
         JWT::InvalidAudError, JWT::InvalidIatError => e
    raise VerificationError, e.message
  end

  private

  def decode_options
    {
      algorithm: "RS256",
      verify_iss: true,
      iss: "https://securetoken.google.com/#{@project_id}",
      verify_aud: true,
      aud: @project_id,
      verify_iat: true
    }
  end

  def fetch_certificates
    Rails.cache.fetch("firebase_certificates", expires_in: 1.hour) do
      response = Net::HTTP.get(URI(CERTS_URL))
      JSON.parse(response)
    end
  end
end
