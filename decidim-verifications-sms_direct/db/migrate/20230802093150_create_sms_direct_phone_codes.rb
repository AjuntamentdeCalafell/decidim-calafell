# frozen_string_literal: true

class CreateSmsDirectPhoneCodes < ActiveRecord::Migration[6.0]
  def change
    create_table :decidim_verifications_sms_direct_phone_codes do |t|
      t.belongs_to :decidim_organization, null: false, index: { name: "idx_sms_direct_phone_codes_on_org_id" }
      t.string :phone_number
      t.string :code

      t.timestamps
    end

    add_index :decidim_verifications_sms_direct_phone_codes, [:decidim_organization_id, :phone_number, :code], unique: true, name: "idx_sms_direct_primary"
  end
end
