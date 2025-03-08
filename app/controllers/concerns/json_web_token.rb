require "jwt"

module JsonWebToken
  extend ActiveSupport::Concern
  SECRET_KEY = Rails.application.secret_key_base

  def jwt_encode(payload, exp = 7.days.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end

  def jwt_decode(token)
    decoded = JWT.decode(token, SECRET_KEY)[0]
    HashWithIndifferentAccess.new decoded
  end

  def jwt_valid_payload(payload)
    logger.info "@----------------------- #{payload} -----------------------"
    if expired(payload) || payload["iss"] != meta[:iss] || payload["aud"] != meta[:aud]
      false
    else
      true
    end
  end

  def expired(payload)
    logger.info "@----------------------- #{payload["exp"]} -----------------------"
    Time.at(payload["exp"]) < Time.now
  end
end
