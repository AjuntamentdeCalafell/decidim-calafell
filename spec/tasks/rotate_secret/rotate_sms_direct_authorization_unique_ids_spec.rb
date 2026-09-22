# frozen_string_literal: true

require "rails_helper"

load Rails.root.join("lib/tasks/rotate_secret/shared.rake") unless defined?(RotateSecretTaskSupport)
load Rails.root.join("lib/tasks/rotate_secret/sms_unique_ids.rake") unless defined?(RotateSmsDirectAuthorizationUniqueIds)

RSpec.describe RotateSmsDirectAuthorizationUniqueIds do
  let(:old_secret_key_base) { "old-secret-key-base" }
  let(:current_secret_key_base) { "current-secret-key-base" }
  let(:current_encryptor) { Decidim::AttributeEncryptor.cryptor }
  let(:old_encryptor) { RotateSecretTaskSupport.encryptor(old_secret_key_base, salt: "attribute") }
  let(:organization) { instance_double(Decidim::Organization, id: 42) }
  let(:user) { instance_double(Decidim::User, organization: organization) }
  let(:authorization) { instance_double(Decidim::Authorization, id: 7, user: user, unique_id: old_unique_id, read_attribute: metadata) }
  let(:phone_number) { "+34600111222" }
  let(:old_unique_id) { Digest::MD5.hexdigest("#{organization.id}-#{phone_number}-#{old_secret_key_base}") }
  let(:metadata) do
    {
      "phone_number" => old_encryptor.encrypt_and_sign(ActiveSupport::JSON.encode(phone_number))
    }
  end

  it "recomputes the unique_id with the current secret key when the old metadata is still stored" do
    extracted = described_class.phone_number_from_metadata(metadata, current_encryptor: current_encryptor, old_encryptor: old_encryptor)
    expect(Digest::MD5.hexdigest("#{organization.id}-#{extracted}-#{current_secret_key_base}")).to eq(
      Digest::MD5.hexdigest("#{organization.id}-#{phone_number}-#{current_secret_key_base}")
    )
  end

  it "keeps the current unique_id when it already matches the current secret key" do
    current_unique_id = Digest::MD5.hexdigest("#{organization.id}-#{phone_number}-#{current_secret_key_base}")
    extracted = described_class.phone_number_from_metadata(metadata, current_encryptor: current_encryptor, old_encryptor: old_encryptor)
    computed = Digest::MD5.hexdigest("#{organization.id}-#{extracted}-#{current_secret_key_base}")

    expect(computed).to eq(current_unique_id)
  end

  it "raises when the phone number cannot be recovered from metadata" do
    expect do
      described_class.phone_number_from_metadata({ "phone_number" => "not-encrypted" }, current_encryptor: current_encryptor, old_encryptor: old_encryptor)
    end.to raise_error("phone number cannot be decrypted with the current or old key")
  end
end
