# frozen_string_literal: true

module RotateOrganizationOmniauthSettings
  module_function

  def run!
    options = options_from_env!
    old_encryptor = encryptor(options[:old_secret_key_base])
    current_encryptor = Decidim::AttributeEncryptor.cryptor

    totals = Hash.new(0)

    Decidim::Organization.unscoped.find_each(batch_size: options[:batch_size]) do |organization|
      omniauth_settings = organization.read_attribute(:omniauth_settings)

      if omniauth_settings.blank?
        totals[:empty] += 1
        next
      end

      rotated_settings = rotate_settings(omniauth_settings, old_encryptor: old_encryptor, current_encryptor: current_encryptor)
      if rotated_settings
        organization.update(omniauth_settings: rotated_settings) unless options[:dry_run]
        totals[:updated] += 1
      else
        totals[:current] += 1
      end
    rescue StandardError => e
      totals[:failed] += 1
      warn "Organization #{organization.id}: #{e.message}"
    end

    summary = [:updated, :current, :empty, :failed].map { |key| "#{key}=#{totals[key]}" }.join(", ")
    puts "Organization omniauth_settings rotation#{" (dry run)" if options[:dry_run]}: #{summary}"
    abort format("Rotation finished with %{failed} failures", failed: totals[:failed]) if totals[:failed].positive?
  end

  def options_from_env!
    old_secret_key_base = ENV.fetch("OLD_SECRET_KEY_BASE", nil)
    abort "Set OLD_SECRET_KEY_BASE before running this task" if old_secret_key_base.blank?

    {
      old_secret_key_base: old_secret_key_base,
      dry_run: ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", "false")),
      batch_size: Integer(ENV.fetch("BATCH_SIZE", "1000"))
    }
  end

  def rotate_settings(omniauth_settings, old_encryptor:, current_encryptor:)
    return unless omniauth_settings.is_a?(Hash)

    changed = false
    rotated = omniauth_settings.transform_values do |value|
      next value unless Decidim::OmniauthProvider.value_defined?(value)
      next value if decrypt(current_encryptor, value)

      decrypted = decrypt(old_encryptor, value)
      raise "value cannot be decrypted with the current or old key" unless decrypted

      changed = true
      current_encryptor.encrypt_and_sign(decrypted)
    end

    rotated if changed
  end

  def encryptor(secret_key_base)
    key = ActiveSupport::KeyGenerator.new("attribute").generate_key(
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
end

namespace :rotate_secret do
  desc "Rotate Decidim::Organization omniauth_settings using the current SECRET_KEY_BASE"
  task org_omniauth: :environment do
    RotateOrganizationOmniauthSettings.run!
  end
end
