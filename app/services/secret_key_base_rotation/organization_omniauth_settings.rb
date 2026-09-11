# frozen_string_literal: true

module SecretKeyBaseRotation
  class OrganizationOmniauthSettings
    class UndecryptableValue < StandardError; end

    def initialize(old_secret_key_base:, current_encryptor: Decidim::AttributeEncryptor.cryptor)
      @old_encryptor = self.class.encryptor(old_secret_key_base)
      @current_encryptor = current_encryptor
    end

    def rotate(omniauth_settings)
      return unless omniauth_settings.is_a?(Hash)

      changed = false
      rotated = omniauth_settings.transform_values do |value|
        next value unless Decidim::OmniauthProvider.value_defined?(value)
        next value if decrypt(@current_encryptor, value)

        decrypted = decrypt(@old_encryptor, value)
        raise UndecryptableValue, "value cannot be decrypted with the current or old key" unless decrypted

        changed = true
        @current_encryptor.encrypt_and_sign(decrypted)
      end

      rotated if changed
    end

    def self.encryptor(secret_key_base)
      key = ActiveSupport::KeyGenerator.new("attribute").generate_key(
        secret_key_base,
        ActiveSupport::MessageEncryptor.key_len
      )
      ActiveSupport::MessageEncryptor.new(key)
    end

    private

    def decrypt(encryptor, value)
      encryptor.decrypt_and_verify(value)
    rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end
  end
end
