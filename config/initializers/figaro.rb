# frozen_string_literal: true

env = Rails.env
keys = %w(SECRET_KEY_BASE)
unless env.development? || env.test?
  Figaro.require_keys(
    "DB_DATABASE",
    "DB_PASSWORD",
    "DB_USERNAME",
    "DATABASE_URL"
  )

  keys += %w(DATABASE_URL)
  keys += %w(MAILER_SMTP_ADDRESS MAILER_SMTP_DOMAIN MAILER_SMTP_PORT MAILER_SMTP_USER_NAME MAILER_SMTP_PASSWORD)
  keys += %w(HERE_API_KEY)
  keys += %w(AWS_ACCESS_KEY_ID AWS_BUCKET AWS_BUCKET_NAME AWS_HOST AWS_REGION AWS_SECRET_ACCESS_KEY)
  keys += %w(SMS_API_TOKEN SMS_CONFIGURATION_NAME SMS_PASSWORD SMS_SERVICE_ID SMS_SERVICE_URL SMS_USERNAME)
end
Figaro.require_keys(keys)
