# frozen_string_literal: true

require "spec_helper"
RSpec.describe Decidim::Verifications::SmsDirect::SmsCodesController, type: :controller do
  # include Warden::Test::Helpers

  routes { Decidim::Verifications::SmsDirect::Engine.routes }

  let(:organization) do
    FactoryBot.create :organization,
                      available_authorizations: ["sms_direct"]
  end

  let(:user) do
    FactoryBot.create :user, :confirmed, organization: organization
  end

  before do
    sign_in user
    controller.request.env["decidim.current_organization"] = organization
  end

  describe "POST #send_code" do
    let(:phone_number) { 600000000 }

    it "returns succeeds" do
      post :create, params: {phone_num: phone_number}
      expect(response).to have_http_status(:success)

      auth= Decidim::Authorization.find_by(user: user, name: "sms_direct")
      expect(auth).to be_present
      expect(auth.unique_id).to be_nil
      expect(JSON.parse(response.body)['metadata']).to include(auth.metadata)
    end
  end
end
