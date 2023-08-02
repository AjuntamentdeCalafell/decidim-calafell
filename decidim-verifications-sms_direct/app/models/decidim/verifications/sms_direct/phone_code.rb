# frozen_string_literal: true

module Decidim
  module Verifications
    module SmsDirect
      class PhoneCode < ApplicationRecord
        EXPIRATION_DAYS= 1

        belongs_to :organization, foreign_key: :decidim_organization_id,
                                class_name: "Decidim::Organization"

        scope :expired, -> { where("updated_at < ?", Time.zone.now - EXPIRATION_DAYS.days) }

        # An organzation scope
        def self.inside(organization)
          where(decidim_organization_id: organization.id)
        end

        # Clear all expired codes for all organizations
        def self.clear_expired
          PhoneCode.expired.delete_all
        end
      end
    end
  end
end
