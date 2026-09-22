# frozen_string_literal: true

module RotateSecretTaskSupport
  module_function

  def rotation_options!
    {
      old_secret_key_base: old_secret_key_base!,
      dry_run: ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", "false")),
      batch_size: Integer(ENV.fetch("BATCH_SIZE", "1000"))
    }
  end

  def old_secret_key_base!
    old_secret_key_base = ENV.fetch("OLD_SECRET_KEY_BASE", nil)
    abort "Set OLD_SECRET_KEY_BASE before running this task" if old_secret_key_base.blank?

    old_secret_key_base
  end

  def encryptor(secret_key_base, salt:)
    key = ActiveSupport::KeyGenerator.new(salt).generate_key(
      secret_key_base,
      ActiveSupport::MessageEncryptor.key_len
    )
    ActiveSupport::MessageEncryptor.new(key)
  end

  def decrypt(encryptor, value)
    encryptor.decrypt_and_verify(value)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end

  def decrypt_json(encryptor, value)
    plaintext = decrypt(encryptor, value)
    ActiveSupport::JSON.decode(plaintext)
  rescue JSON::ParserError, TypeError
    nil
  end

  def decrypt_json_string(encryptor, value)
    plaintext = decrypt(encryptor, value)
    ActiveSupport::JSON.decode(plaintext)
    plaintext
  rescue JSON::ParserError, TypeError
    nil
  end
end
