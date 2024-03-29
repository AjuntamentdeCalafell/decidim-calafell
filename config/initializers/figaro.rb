# frozen_string_literal: true

env = Rails.env
keys = %w(SECRET_KEY_BASE)
unless env.development? || env.test?
  keys += %w(DATABASE_URL)
  keys += %w(SENDGRID_API_KEY SENDGRID_PASSWORD SENDGRID_USERNAME)
  keys += %w(GEOCODER_LOOKUP_API_KEY)
  keys += %w(AWS_ACCESS_KEY_ID AWS_BUCKET AWS_BUCKET_NAME AWS_HOST AWS_REGION AWS_SECRET_ACCESS_KEY)
  keys += %w(SMS_API_TOKEN SMS_CONFIGURATION_NAME SMS_PASSWORD SMS_SERVICE_ID SMS_SERVICE_URL SMS_USERNAME)
end
Figaro.require_keys(keys)
