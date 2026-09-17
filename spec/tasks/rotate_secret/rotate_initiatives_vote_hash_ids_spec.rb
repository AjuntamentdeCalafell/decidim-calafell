# frozen_string_literal: true

require "rails_helper"

load Rails.root.join("lib/tasks/rotate_secret/vote_hash_ids.rake") unless defined?(RotateInitiativesVoteHashIds)

RSpec.describe RotateInitiativesVoteHashIds do
  let(:old_secret_key_base) { "old-secret-key-base" }
  let(:current_secret_key_base) { "current-secret-key-base" }
  let(:current_encryptor) { described_class.encryptor(current_secret_key_base) }
  let(:old_encryptor) { described_class.encryptor(old_secret_key_base) }

  it "generates the same hash as VoteForm for votes without personal metadata" do
    vote = instance_double(
      Decidim::InitiativesVote,
      decidim_initiative_id: 7,
      decidim_author_id: 12,
      encrypted_metadata: nil
    )

    expected = Digest::MD5.hexdigest("7-12-#{current_secret_key_base}")

    identifier = described_class.identifier(vote, current_encryptor: current_encryptor, old_encryptor: old_encryptor)
    expect(Digest::MD5.hexdigest("7-#{identifier}-#{current_secret_key_base}")).to eq(expected)
  end

  it "uses the document number from metadata encrypted with the old key" do
    metadata = { document_number: "12345678A" }
    encrypted_metadata = described_class.encryptor(old_secret_key_base).encrypt_and_sign(metadata)
    vote = instance_double(
      Decidim::InitiativesVote,
      decidim_initiative_id: 7,
      decidim_author_id: 12,
      encrypted_metadata: encrypted_metadata
    )

    expected = Digest::MD5.hexdigest("7-12345678A-#{current_secret_key_base}")

    identifier = described_class.identifier(vote, current_encryptor: current_encryptor, old_encryptor: old_encryptor)
    expect(Digest::MD5.hexdigest("7-#{identifier}-#{current_secret_key_base}")).to eq(expected)
  end

  it "supports metadata already encrypted with the current key" do
    metadata = { document_number: "12345678A" }
    encrypted_metadata = described_class.encryptor(current_secret_key_base).encrypt_and_sign(metadata)
    vote = instance_double(
      Decidim::InitiativesVote,
      decidim_initiative_id: 7,
      decidim_author_id: 12,
      encrypted_metadata: encrypted_metadata
    )

    expected = Digest::MD5.hexdigest("7-12345678A-#{current_secret_key_base}")

    identifier = described_class.identifier(vote, current_encryptor: current_encryptor, old_encryptor: old_encryptor)
    expect(Digest::MD5.hexdigest("7-#{identifier}-#{current_secret_key_base}")).to eq(expected)
  end

  it "fails when encrypted metadata cannot be decrypted" do
    vote = instance_double(
      Decidim::InitiativesVote,
      decidim_initiative_id: 7,
      decidim_author_id: 12,
      encrypted_metadata: "not-encrypted"
    )

    expect do
      described_class.decrypt_metadata(vote.encrypted_metadata, current_encryptor: current_encryptor, old_encryptor: old_encryptor)
    end.to raise_error("encrypted_metadata cannot be decrypted with the current or old key")
  end
end
