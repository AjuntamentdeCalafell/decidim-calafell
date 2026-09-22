# frozen_string_literal: true

require_relative "rotate_secret_task_support"

module RotateAuthorizationMetadata
  module_function

  def run!
    options = RotateSecretTaskSupport.rotation_options!
    old_encryptor = RotateSecretTaskSupport.encryptor(options[:old_secret_key_base], salt: "attribute")
    current_encryptor = Decidim::AttributeEncryptor.cryptor

    totals = Hash.new(0)

    Decidim::Authorization.unscoped.find_each(batch_size: options[:batch_size]) do |authorization|
      metadata = authorization.read_attribute(:metadata)

      if metadata.blank?
        totals[:empty] += 1
        next
      end

      rotated_metadata = rotate_metadata(metadata, old_encryptor: old_encryptor, current_encryptor: current_encryptor)
      if rotated_metadata
        authorization.update(metadata: rotated_metadata) unless options[:dry_run]
        totals[:updated] += 1
      else
        totals[:current] += 1
      end
    rescue StandardError => e
      totals[:failed] += 1
      warn "Authorization #{authorization.id}: #{e.message}"
    end

    summary = [:updated, :current, :empty, :failed].map { |key| "#{key}=#{totals[key]}" }.join("\n")
    puts "Authorization metadata rotation#{" (dry run)" if options[:dry_run]}: #{summary}"
    abort format("Rotation finished with %{failed} failures", failed: totals[:failed]) if totals[:failed].positive?
  end

  def rotate_metadata(metadata, old_encryptor:, current_encryptor:)
    return unless metadata.is_a?(Hash)

    changed = false
    rotated = metadata.transform_values do |value|
      next value unless value.is_a?(String)
      next value if RotateSecretTaskSupport.decrypt_json_string(current_encryptor, value)

      decrypted = RotateSecretTaskSupport.decrypt_json_string(old_encryptor, value)
      raise "value cannot be decrypted with the current or old key" unless decrypted

      changed = true
      current_encryptor.encrypt_and_sign(decrypted)
    end

    rotated if changed
  end
end

namespace :rotate_secret do
  desc "Rotate Decidim::Authorization metadata using the current SECRET_KEY_BASE"
  task auth_metadata: :environment do
    RotateAuthorizationMetadata.run!
  end
end
