# frozen_string_literal: true
require_relative "rotate_secret_task_support"

module RotateInitiativesVoteHashIds
  module_function

  def run!
    options = RotateSecretTaskSupport.rotation_options!
    current_secret_key_base = Rails.application.secret_key_base
    current_encryptor = RotateSecretTaskSupport.encryptor(current_secret_key_base, salt: "personal user metadata")
    old_encryptor = RotateSecretTaskSupport.encryptor(options[:old_secret_key_base], salt: "personal user metadata")

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

    summary = [:updated, :current, :failed].map { |key| "#{key}=#{totals[key]}" }.join("\n")
    puts "InitiativesVote hash ID rotation#{" (dry run)" if options[:dry_run]}: #{summary}"
    abort format("Rotation finished with %{failed} failures", failed: totals[:failed]) if totals[:failed].positive?
  end

  def identifier(vote, current_encryptor:, old_encryptor:)
    metadata = decrypt_metadata(vote.encrypted_metadata, current_encryptor: current_encryptor, old_encryptor: old_encryptor)
    metadata&.with_indifferent_access&.fetch(:document_number, nil).presence || vote.decidim_author_id
  end

  def decrypt_metadata(encrypted_metadata, current_encryptor:, old_encryptor:)
    return if encrypted_metadata.blank?

    RotateSecretTaskSupport.decrypt(current_encryptor, encrypted_metadata) ||
      RotateSecretTaskSupport.decrypt(old_encryptor, encrypted_metadata) ||
      raise("encrypted_metadata cannot be decrypted with the current or old key")
  end
end

namespace :rotate_secret do
  desc "Rotate Decidim::InitiativesVote hash IDs using the current SECRET_KEY_BASE"
  task vote_hash_ids: :environment do
    RotateInitiativesVoteHashIds.run!
  end
end
