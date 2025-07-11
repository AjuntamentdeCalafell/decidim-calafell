# frozen_string_literal: true

module Decidim
  module Verifications
    module SmsDirect
      class PhoneCode < ApplicationRecord
        EXPIRATION_DAYS= 1

        belongs_to :organization, foreign_key: :decidim_organization_id,
                                  class_name: "Decidim::Organization"

        before_save :normalize_phone

        scope :expired, -> { where(updated_at: ...(Time.zone.now - EXPIRATION_DAYS.days)) }

        # An organization scope
        def self.inside(organization)
          where(decidim_organization_id: organization.id)
        end

        # Clear all expired codes for all organizations
        def self.clear_expired
          PhoneCode.expired.delete_all
        end

        def normalize_phone
          self.phone_number = SmsDirectHandler.normalize_phone_number(phone_number)
        end
      end
    end
  end
end
