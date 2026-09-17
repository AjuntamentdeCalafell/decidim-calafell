# frozen_string_literal: true

module RotateInitiativesVoteHashIds
  module_function

  def run!
    options = options_from_env!
    current_secret_key_base = Rails.application.secret_key_base
    current_encryptor = encryptor(current_secret_key_base)
    old_encryptor = encryptor(options[:old_secret_key_base])

    totals = Hash.new(0)

    Decidim::InitiativesVote.unscoped.find_each(batch_size: options[:batch_size]) do |vote|
      hash_id = Digest::MD5.hexdigest(
        [vote.decidim_initiative_id, identifier(vote, current_encryptor: current_encryptor, old_encryptor: old_encryptor), current_secret_key_base].compact.join("-")
      )

      if hash_id == vote.hash_id
        totals[:current] += 1
      else
        vote.update(hash_id: hash_id) unless options[:dry_run]
        totals[:updated] += 1
      end
    rescue StandardError => e
      totals[:failed] += 1
      warn "InitiativesVote #{vote.id}: #{e.message}"
    end

    summary = [:updated, :current, :failed].map { |key| "#{key}=#{totals[key]}" }.join(", ")
    puts "InitiativesVote hash ID rotation#{" (dry run)" if options[:dry_run]}: #{summary}"
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

  def encryptor(secret_key_base)
    key = ActiveSupport::KeyGenerator.new("personal user metadata").generate_key(
      secret_key_base,
      ActiveSupport::MessageEncryptor.key_len
    )
    ActiveSupport::MessageEncryptor.new(key)
  end

  def identifier(vote, current_encryptor:, old_encryptor:)
    metadata = decrypt_metadata(vote.encrypted_metadata, current_encryptor: current_encryptor, old_encryptor: old_encryptor)
    metadata&.with_indifferent_access&.fetch(:document_number, nil).presence || vote.decidim_author_id
  end

  def decrypt_metadata(encrypted_metadata, current_encryptor:, old_encryptor:)
    return if encrypted_metadata.blank?

    decrypt(current_encryptor, encrypted_metadata) ||
      decrypt(old_encryptor, encrypted_metadata) ||
      raise("encrypted_metadata cannot be decrypted with the current or old key")
  end

  def decrypt(encryptor, encrypted_metadata)
    encryptor.decrypt_and_verify(encrypted_metadata)
  rescue ActiveSupport::MessageEncryptor::InvalidMessage, ActiveSupport::MessageVerifier::InvalidSignature
    nil
  end
end

namespace :rotate_secret do
  desc "Rotate Decidim::InitiativesVote hash IDs using the current SECRET_KEY_BASE"
  task vote_hash_ids: :environment do
    RotateInitiativesVoteHashIds.run!
  end
end
