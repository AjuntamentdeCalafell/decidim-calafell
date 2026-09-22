# frozen_string_literal: true

require "rails_helper"

load Rails.root.join("lib/tasks/rotate_secret/shared.rake") unless defined?(RotateSecretTaskSupport)
load Rails.root.join("lib/tasks/rotate_secret/org_omniauth.rake") unless defined?(RotateOrganizationOmniauthSettings)

RSpec.describe RotateOrganizationOmniauthSettings do
  let(:old_encryptor) { RotateSecretTaskSupport.encryptor("old-secret-key-base", salt: "attribute") }
  let(:current_encryptor) { RotateSecretTaskSupport.encryptor("current-secret-key-base", salt: "attribute") }

  it "re-encrypts secret values encrypted with the old key" do
    omniauth_settings = {
      "omniauth_settings_facebook_enabled" => true,
      "omniauth_settings_facebook_app_id" => old_encryptor.encrypt_and_sign("app-id"),
      "omniauth_settings_facebook_app_secret" => old_encryptor.encrypt_and_sign("app-secret")
    }

    rotated = described_class.rotate_settings(omniauth_settings, old_encryptor: old_encryptor, current_encryptor: current_encryptor)

    expect(rotated["omniauth_settings_facebook_enabled"]).to be(true)
    expect(current_encryptor.decrypt_and_verify(rotated["omniauth_settings_facebook_app_id"])).to eq("app-id")
    expect(current_encryptor.decrypt_and_verify(rotated["omniauth_settings_facebook_app_secret"])).to eq("app-secret")
  end

  it "does not rewrite values already encrypted with the current key" do
    omniauth_settings = {
      "omniauth_settings_facebook_app_id" => current_encryptor.encrypt_and_sign("app-id")
    }

    expect(described_class.rotate_settings(omniauth_settings, old_encryptor: old_encryptor, current_encryptor: current_encryptor)).to be_nil
  end

  it "leaves blank or boolean values untouched" do
    omniauth_settings = {
      "omniauth_settings_facebook_enabled" => false,
      "omniauth_settings_facebook_app_id" => ""
    }

    expect(described_class.rotate_settings(omniauth_settings, old_encryptor: old_encryptor, current_encryptor: current_encryptor)).to be_nil
  end

  it "fails without returning partially rotated settings when a value cannot be decrypted" do
    omniauth_settings = { "omniauth_settings_facebook_app_id" => "not-encrypted" }

    expect do
      described_class.rotate_settings(omniauth_settings, old_encryptor: old_encryptor, current_encryptor: current_encryptor)
    end.to raise_error("value cannot be decrypted with the current or old key")
  end
end
