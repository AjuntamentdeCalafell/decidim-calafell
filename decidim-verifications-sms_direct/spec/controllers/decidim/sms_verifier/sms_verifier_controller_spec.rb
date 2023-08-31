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
    let(:phone_number) { "600000000" }

    it "returns succeeds" do
      post :create, params: {phone_num: phone_number}
      expect(response).to have_http_status(:success)

      phone_code= Decidim::Verifications::SmsDirect::PhoneCode.inside(organization).last
      expect(phone_code).to be_present
      expect(phone_code.phone_number).to eq("+34600000000")
      expect(phone_code.code).to be_present
      expect(phone_code).to be_present
      expect(JSON.parse(response.body)['phone_number']).to eq("+34600000000")
    end
  end
end
