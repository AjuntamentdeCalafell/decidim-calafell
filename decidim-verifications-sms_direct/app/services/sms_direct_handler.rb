# frozen_string_literal: true

require "securerandom"

# A form object to be used when public users want to get verified using their phone number.
class SmsDirectHandler < Decidim::AuthorizationHandler
  attribute :mobile_phone_number, String
  attribute :verification_code, String

  validates :mobile_phone_number, :verification_code, :sms_gateway, presence: true
  validates :verification_code, presence: true

  def handler_name
    +"sms"
  end

  # A mobile phone can only be verified once but it should be private.
  def unique_id
    Digest::MD5.hexdigest(
      "#{organization}-#{mobile_phone_number}-#{Rails.application.secrets.secret_key_base}"
    )
  end

  # When there's a phone number, sanitize it allowing only numbers and +.
  def mobile_phone_number
    return unless super

    super.gsub(/[^+0-9]/, "")
  end

  # The verification metadata to validate in the next step.
  def verification_metadata
    {
      verification_code: verification_code,
      code_sent_at: Time.current
    }
  end

  private

  # Returns the verification code.
  # If the attribute is alredy set, returns it.
  # If the attribute is empty, generates and sends it via SMS gateway.
  def verification_code
    return unless sms_gateway
    
    @verification_code||= begin
      generated_code= generate_code!

      return unless sms_gateway.new(mobile_phone_number, generate_code!).deliver_code
      generated_code
    end
  end

  def sms_gateway
    Decidim.sms_gateway_service.to_s.constantize
  end

  def generate_code!
    SecureRandom.random_number(1_000_000).to_s
  end

  def organization
    current_organization || user&.organization || scope&.organization
  end
end
