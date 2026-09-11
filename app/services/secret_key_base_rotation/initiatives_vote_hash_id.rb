# frozen_string_literal: true

module SecretKeyBaseRotation
  class InitiativesVoteHashId
    class UndecryptableMetadata < StandardError; end

    def initialize(old_secret_key_base:, current_secret_key_base: Rails.application.secret_key_base)
      @current_secret_key_base = current_secret_key_base
      @current_encryptor = self.class.encryptor(current_secret_key_base)
      @old_encryptor = self.class.encryptor(old_secret_key_base)
    end

    def generate(vote)
      Digest::MD5.hexdigest(
        [vote.decidim_initiative_id, identifier(vote), @current_secret_key_base].compact.join("-")
      )
    end

    def self.encryptor(secret_key_base)
      key = ActiveSupport::KeyGenerator.new("personal user metadata").generate_key(
        secret_key_base,
        ActiveSupport::MessageEncryptor.key_len
      )
      ActiveSupport::MessageEncryptor.new(key)
    end

    private

    def identifier(vote)
      metadata = decrypt_metadata(vote.encrypted_metadata)
      metadata&.with_indifferent_access&.fetch(:document_number, nil).presence || vote.decidim_author_id
    end

    def decrypt_metadata(encrypted_metadata)
      return if encrypted_metadata.blank?

      decrypt(@current_encryptor, encrypted_metadata) ||
        decrypt(@old_encryptor, encrypted_metadata) ||
        raise(UndecryptableMetadata, "encrypted_metadata cannot be decrypted with the current or old key")
    end

    def decrypt(encryptor, encrypted_metadata)
      encryptor.decrypt_and_verify(encrypted_metadata)
    rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
      nil
    end
  end
end