# frozen_string_literal: true

require "spec_helper"
RSpec.describe Decidim::Verifications::SmsDirect::SmsCodesController,
               type: :controller do
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
      post :post, params: {phone_num: phone_number}
      expect(response).to have_http_status(:success)
      handler= ::SmsDirectHandler.with_context(organization: organization).from_params({mobile_phone_number: phone_num})
      auth= Decidim::Authorization.find_by(unique_id: handler.unique_id)
      expect(response.body).to include("asdf")
    end
  end
end
