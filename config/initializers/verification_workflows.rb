# frozen_string_literal: true

require Rails.root.join("app/services/parlem_sms_gateway")

Decidim::Verifications.register_workflow(:census_authorization_handler) do |auth|
  auth.form = "CensusAuthorizationHandler"
  auth.options do |options|
    options.attribute :postal_code, type: :string, required: false
  end
end
