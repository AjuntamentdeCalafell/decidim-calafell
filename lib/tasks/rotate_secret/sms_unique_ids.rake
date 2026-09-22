# frozen_string_literal: true

require_relative "rotate_secret_task_support"

module RotateSmsDirectAuthorizationUniqueIds
  module_function

  def run!
    options = RotateSecretTaskSupport.rotation_options!
    current_secret_key_base = Rails.application.secret_key_base
    old_encryptor = RotateSecretTaskSupport.encryptor(options[:old_secret_key_base], salt: "attribute")
    current_encryptor = Decidim::AttributeEncryptor.cryptor

    totals = Hash.new(0)

    Decidim::Authorization.unscoped.where(name: "sms_direct").find_each(batch_size: options[:batch_size]) do |authorization|
      metadata = authorization.read_attribute(:metadata)
      phone_number = phone_number_from_metadata(metadata, current_encryptor: current_encryptor, old_encryptor: old_encryptor)
      current_unique_id = Digest::MD5.hexdigest("#{authorization.user.organization.id}-#{phone_number}-#{current_secret_key_base}")

      if current_unique_id == authorization.unique_id
        totals[:current] += 1
      else
        authorization.update(unique_id: current_unique_id) unless options[:dry_run]
        totals[:updated] += 1
      end
    rescue StandardError => e
      totals[:failed] += 1
      warn "Authorization #{authorization.id}: #{e.message}"
    end

    summary = [:updated, :current, :failed].map { |key| "#{key}=#{totals[key]}" }.join("\n")
    puts "SMS direct authorization unique_id rotation#{" (dry run)" if options[:dry_run]}: #{summary}"
    abort format("Rotation finished with %{failed} failures", failed: totals[:failed]) if totals[:failed].positive?
  end

  def phone_number_from_metadata(metadata, current_encryptor:, old_encryptor:)
    raise "phone number metadata is blank" if metadata.blank?

    value = metadata.with_indifferent_access[:phone_number] || metadata["phone_number"]
    raise "phone number metadata is missing" if value.blank?

    decrypted = RotateSecretTaskSupport.decrypt_json(current_encryptor, value) || RotateSecretTaskSupport.decrypt_json(old_encryptor, value)
    raise "phone number cannot be decrypted with the current or old key" if decrypted.blank?

    decrypted
  end
end

namespace :rotate_secret do
  desc "Rotate Decidim::Authorization unique_ids for sms_direct using the current SECRET_KEY_BASE"
  task sms_unique_ids: :environment do
    RotateSmsDirectAuthorizationUniqueIds.run!
  end
end
