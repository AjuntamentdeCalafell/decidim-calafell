# frozen_string_literal: true

require "rails_helper"

RSpec.describe SecretKeyBaseRotation::OrganizationOmniauthSettings do
  let(:old_encryptor) { described_class.encryptor("old-secret-key-base") }
  let(:current_encryptor) { described_class.encryptor("current-secret-key-base") }
  let(:rotator) do
    described_class.new(
      old_secret_key_base: "old-secret-key-base",
      current_encryptor: current_encryptor
    )
  end

  it "re-encrypts secret values encrypted with the old key" do
    omniauth_settings = {
      "omniauth_settings_facebook_enabled" => true,
      "omniauth_settings_facebook_app_id" => old_encryptor.encrypt_and_sign("app-id"),
      "omniauth_settings_facebook_app_secret" => old_encryptor.encrypt_and_sign("app-secret")
    }

    rotated = rotator.rotate(omniauth_settings)

    expect(rotated["omniauth_settings_facebook_enabled"]).to be(true)
    expect(current_encryptor.decrypt_and_verify(rotated["omniauth_settings_facebook_app_id"])).to eq("app-id")
    expect(current_encryptor.decrypt_and_verify(rotated["omniauth_settings_facebook_app_secret"])).to eq("app-secret")
  end

  it "does not rewrite values already encrypted with the current key" do
    omniauth_settings = {
      "omniauth_settings_facebook_app_id" => current_encryptor.encrypt_and_sign("app-id")
    }

    expect(rotator.rotate(omniauth_settings)).to be_nil
  end

  it "leaves blank or boolean values untouched" do
    omniauth_settings = {
      "omniauth_settings_facebook_enabled" => false,
      "omniauth_settings_facebook_app_id" => ""
    }

    expect(rotator.rotate(omniauth_settings)).to be_nil
  end

  it "fails without returning partially rotated settings when a value cannot be decrypted" do
    omniauth_settings = { "omniauth_settings_facebook_app_id" => "not-encrypted" }

    expect { rotator.rotate(omniauth_settings) }.to raise_error(described_class::UndecryptableValue)
  end
end
