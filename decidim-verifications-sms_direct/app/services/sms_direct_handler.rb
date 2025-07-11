# frozen_string_literal: true

require "securerandom"
require "phonelib"

# A form object to be used when public users want to get verified using their phone number.
class SmsDirectHandler < Decidim::AuthorizationHandler
  attribute :mobile_phone_number, String
  attribute :verification_code, String

  validates :mobile_phone_number, :verification_code, :sms_gateway, presence: true
  validates :mobile_phone_number, phone: { countries: :es }
  validate :verification_code_is_correct!

  def handler_name
    +"sms_direct"
  end

  # A mobile phone can only be verified once but it should be private.
  def unique_id
    return unless organization

    Digest::MD5.hexdigest(
      "#{organization.id}-#{mobile_phone_number}-#{Rails.application.secrets.secret_key_base}"
    )
  end

  # When there's a phone number, sanitize it allowing only numbers and +.
  def mobile_phone_number
    return unless super

    SmsDirectHandler.normalize_phone_number(super)
  end

  # The metadata.
  def metadata
    {
      phone_number: mobile_phone_number
    }
  end

  # Generates the verification_code and sends it via Decidim's SMS Gateway.
  def generate_and_send_code
    return unless sms_gateway

    verification_code= generate_code!

    return unless sms_gateway.new(mobile_phone_number, code: verification_code).deliver_code

    verification_code
  end

  def self.normalize_phone_number(number)
    parsed= Phonelib.parse(number, :es)
    parsed.e164 if parsed.valid?
  end

  #------------------------------------------------------------------
  private

  #------------------------------------------------------------------

  def sms_gateway
    Decidim.sms_gateway_service.to_s.constantize
  end

  def generate_code!
    SecureRandom.random_number(1_000_000).to_s
  end

  def organization
    current_organization || user&.organization
  end

  def verification_code_is_correct!
    phone_code= Decidim::Verifications::SmsDirect::PhoneCode.inside(
      user&.organization || current_organization
    ).find_by(phone_number: SmsDirectHandler.normalize_phone_number(mobile_phone_number))

    errors.add(:verification_code, "Unexpected verification_code") if phone_code.nil? || phone_code.code != verification_code
  end
end
