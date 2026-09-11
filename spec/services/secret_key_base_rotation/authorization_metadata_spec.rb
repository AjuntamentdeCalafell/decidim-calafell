# frozen_string_literal: true

require "rails_helper"

RSpec.describe SecretKeyBaseRotation::AuthorizationMetadata do
  let(:old_encryptor) { described_class.encryptor("old-secret-key-base") }
  let(:current_encryptor) { described_class.encryptor("current-secret-key-base") }
  let(:rotator) do
    described_class.new(
      old_secret_key_base: "old-secret-key-base",
      current_encryptor: current_encryptor
    )
  end

  it "re-encrypts each old metadata value with the current key" do
    old_metadata = {
      "document_number" => old_encryptor.encrypt_and_sign(ActiveSupport::JSON.encode("12345678A")),
      "age" => old_encryptor.encrypt_and_sign(ActiveSupport::JSON.encode(42))
    }

    rotated = rotator.rotate(old_metadata)

    expect(ActiveSupport::JSON.decode(current_encryptor.decrypt_and_verify(rotated["document_number"]))).to eq("12345678A")
    expect(ActiveSupport::JSON.decode(current_encryptor.decrypt_and_verify(rotated["age"]))).to eq(42)
  end

  it "does not rewrite metadata already encrypted with the current key" do
    metadata = { "document_number" => current_encryptor.encrypt_and_sign(ActiveSupport::JSON.encode("12345678A")) }

    expect(rotator.rotate(metadata)).to be_nil
  end

  it "fails without returning partially rotated metadata when a value cannot be decrypted" do
    metadata = { "document_number" => "not-encrypted" }

    expect { rotator.rotate(metadata) }.to raise_error(described_class::UndecryptableValue)
  end
end