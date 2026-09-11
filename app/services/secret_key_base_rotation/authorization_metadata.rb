# frozen_string_literal: true

module SecretKeyBaseRotation
  class AuthorizationMetadata
    class UndecryptableValue < StandardError; end

    def initialize(old_secret_key_base:, current_encryptor: Decidim::AttributeEncryptor.cryptor)
      @old_encryptor = self.class.encryptor(old_secret_key_base)
      @current_encryptor = current_encryptor
    end

    def rotate(metadata)
      return unless metadata.is_a?(Hash)

      changed = false
      rotated = metadata.transform_values do |value|
        next value unless value.is_a?(String)
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
      plaintext = encryptor.decrypt_and_verify(value)
      ActiveSupport::JSON.decode(plaintext)
      plaintext
    rescue ActiveSupport::MessageEncryptor::InvalidMessage,
           ActiveSupport::MessageVerifier::InvalidSignature,
           JSON::ParserError,
           TypeError
      nil
    end
  end
end