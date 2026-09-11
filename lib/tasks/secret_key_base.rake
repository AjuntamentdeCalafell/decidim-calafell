# frozen_string_literal: true

namespace :secret_key_base do
  desc "Re-encrypt Decidim::Authorization metadata using the current SECRET_KEY_BASE"
  task rotate_authorization_metadata: :environment do
    options = secret_key_base_rotation_options
    rotator = SecretKeyBaseRotation::AuthorizationMetadata.new(old_secret_key_base: options[:old_secret_key_base])
    totals = process_rotation_records(
      scope: Decidim::Authorization.unscoped,
      options: options,
      failure_class: SecretKeyBaseRotation::AuthorizationMetadata::UndecryptableValue,
      failure_label: "Authorization"
    ) do |authorization|
      metadata = authorization.read_attribute(:metadata)
      next [:empty] if metadata.blank?

      rotated_metadata = rotator.rotate(metadata)
      if rotated_metadata
        [:updated, { metadata: rotated_metadata }]
      else
        [:current]
      end
    end

    print_rotation_summary(
      label: "Authorization metadata rotation",
      options: options,
      totals: totals,
      keys: [:updated, :current, :empty, :failed]
    )

    abort_on_rotation_failures!(totals, "Rotation finished with %{failed} failures")
  end

  desc "Regenerate Decidim::InitiativesVote hash IDs using the current SECRET_KEY_BASE"
  task regenerate_initiatives_vote_hash_ids: :environment do
    options = secret_key_base_rotation_options
    generator = SecretKeyBaseRotation::InitiativesVoteHashId.new(old_secret_key_base: options[:old_secret_key_base])
    totals = process_rotation_records(
      scope: Decidim::InitiativesVote.unscoped,
      options: options,
      failure_class: SecretKeyBaseRotation::InitiativesVoteHashId::UndecryptableMetadata,
      failure_label: "InitiativesVote"
    ) do |vote|
      hash_id = generator.generate(vote)
      if hash_id == vote.hash_id
        [:current]
      else
        [:updated, { hash_id: hash_id }]
      end
    end

    print_rotation_summary(
      label: "InitiativesVote hash ID regeneration",
      options: options,
      totals: totals,
      keys: [:updated, :current, :failed]
    )

    abort_on_rotation_failures!(totals, "Regeneration finished with %{failed} failures")
  end

  desc "Re-encrypt Decidim::Organization omniauth_settings using the current SECRET_KEY_BASE"
  task rotate_organization_omniauth_settings: :environment do
    options = secret_key_base_rotation_options
    rotator = SecretKeyBaseRotation::OrganizationOmniauthSettings.new(old_secret_key_base: options[:old_secret_key_base])
    totals = process_rotation_records(
      scope: Decidim::Organization.unscoped,
      options: options,
      failure_class: SecretKeyBaseRotation::OrganizationOmniauthSettings::UndecryptableValue,
      failure_label: "Organization"
    ) do |organization|
      omniauth_settings = organization.read_attribute(:omniauth_settings)
      next [:empty] if omniauth_settings.blank?

      rotated_settings = rotator.rotate(omniauth_settings)
      if rotated_settings
        [:updated, { omniauth_settings: rotated_settings }]
      else
        [:current]
      end
    end

    print_rotation_summary(
      label: "Organization omniauth_settings rotation",
      options: options,
      totals: totals,
      keys: [:updated, :current, :empty, :failed]
    )

    abort_on_rotation_failures!(totals, "Rotation finished with %{failed} failures")
  end
end

def secret_key_base_rotation_options
  old_secret_key_base = ENV.fetch("OLD_SECRET_KEY_BASE", nil)
  abort "Set OLD_SECRET_KEY_BASE before running this task" if old_secret_key_base.blank?

  {
    old_secret_key_base: old_secret_key_base,
    dry_run: ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", "false")),
    batch_size: Integer(ENV.fetch("BATCH_SIZE", "1000"))
  }
end

def abort_on_rotation_failures!(totals, message)
  abort format(message, failed: totals[:failed]) if totals[:failed].positive?
end

def process_rotation_records(scope:, options:, failure_class:, failure_label:)
  totals = Hash.new(0)

  scope.find_each(batch_size: options[:batch_size]) do |record|
    status, attributes = yield(record)

    case status
    when :empty
      totals[:empty] += 1
    when :current
      totals[:current] += 1
    when :updated
      record.class.unscoped.where(id: record.id).update_all(attributes) unless options[:dry_run]
      totals[:updated] += 1
    else
      raise ArgumentError, "Unknown rotation status: #{status.inspect}"
    end
  rescue failure_class => e
    totals[:failed] += 1
    warn "#{failure_label} #{record.id}: #{e.message}"
  end

  totals
end

def print_rotation_summary(label:, options:, totals:, keys:)
  summary = keys.map { |key| "#{key}=#{totals[key]}" }.join(", ")
  puts "#{label}#{" (dry run)" if options[:dry_run]}: #{summary}"
end
