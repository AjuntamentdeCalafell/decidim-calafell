# frozen_string_literal: true

require "rails_helper"

load Rails.root.join("lib/tasks/rotate_secret/auth_metadata.rake") unless defined?(RotateAuthorizationMetadata)

RSpec.describe RotateAuthorizationMetadata do
  let(:old_encryptor) { described_class.encryptor("old-secret-key-base") }
  let(:current_encryptor) { described_class.encryptor("current-secret-key-base") }

  it "re-encrypts each old metadata value with the current key" do
    old_metadata = {
      "document_number" => old_encryptor.encrypt_and_sign(ActiveSupport::JSON.encode("12345678A")),
      "age" => old_encryptor.encrypt_and_sign(ActiveSupport::JSON.encode(42))
    }

    rotated = described_class.rotate_metadata(old_metadata, old_encryptor: old_encryptor, current_encryptor: current_encryptor)

    expect(ActiveSupport::JSON.decode(current_encryptor.decrypt_and_verify(rotated["document_number"]))).to eq("12345678A")
    expect(ActiveSupport::JSON.decode(current_encryptor.decrypt_and_verify(rotated["age"]))).to eq(42)
  end

  it "does not rewrite metadata already encrypted with the current key" do
    metadata = { "document_number" => current_encryptor.encrypt_and_sign(ActiveSupport::JSON.encode("12345678A")) }

    expect(described_class.rotate_metadata(metadata, old_encryptor: old_encryptor, current_encryptor: current_encryptor)).to be_nil
  end

  it "fails without returning partially rotated metadata when a value cannot be decrypted" do
    metadata = { "document_number" => "not-encrypted" }

    expect do
      described_class.rotate_metadata(metadata, old_encryptor: old_encryptor, current_encryptor: current_encryptor)
    end.to raise_error("value cannot be decrypted with the current or old key")
  end
end
