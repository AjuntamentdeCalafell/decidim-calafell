# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/authorization_shared_examples"

describe SmsDirectHandler do
  subject { handler }

  let(:handler) { described_class.from_params(params) }
  let(:mobile_phone_number) { "666778899" }
  let(:verification_code) { nil }
  let(:params) do
    {
      mobile_phone_number:,
      verification_code:
    }
  end
  let(:user) { create(:user) }

  # rubocop: disable Lint/ConstantDefinitionInBlock
  # rubocop: disable Style/RedundantInitialize
  class FailingGateway
    def initialize(number, code); end

    def deliver_code
      false
    end
  end
  # rubocop: enable Style/RedundantInitialize
  # rubocop: enable Lint/ConstantDefinitionInBlock

  before do
    handler.user = user
  end

  context "when sending the SMS code" do
    before do
      Phonelib.default_country = "ES"
      handler.valid?
    end

    it_behaves_like "an authorization handler"

    describe "mobile_phone_number" do
      context "when it isn't present" do
        let(:mobile_phone_number) { nil }

        it "raises error" do
          expect(handler.errors.attribute_names).to include(:mobile_phone_number)
        end
      end

      context "with an invalid format" do
        let(:mobile_phone_number) { "-----" }

        it "raises error" do
          expect(handler.errors.attribute_names).to include(:mobile_phone_number)
        end
      end

      context "when it can not be a phone number" do
        let(:mobile_phone_number) { "000000000" }

        it "raises error" do
          expect(handler.errors.attribute_names).to include(:mobile_phone_number)
        end
      end

      context "when it is a valid phone number" do
        let(:mobile_phone_number) { "666121212" }

        it "does not raise error" do
          expect(handler.errors.attribute_names).not_to include(:mobile_phone_number)
        end
      end
    end

    context "when sending the SMS fails" do
      let(:previous_gateway) { Decidim.sms_gateway_service }

      before do
        Decidim.sms_gateway_service= FailingGateway.name
      end

      after do
        Decidim.sms_gateway_service= previous_gateway
      end

      it { is_expected.not_to be_valid }
    end

    context "when sending the SMS succeeds" do
      it { is_expected.to be_invalid }
    end
  end

  describe "unique_id" do
    it "generates a different ID for a different phone number" do
      handler.mobile_phone_number = "666111111"
      unique_id_1 = handler.unique_id

      handler.mobile_phone_number = "666222222"
      unique_id_2 = handler.unique_id

      expect(unique_id_1).not_to eq(unique_id_2)
    end

    it "generates the same ID for the same phone number" do
      handler.mobile_phone_number = "ABC123"
      unique_id_1 = handler.unique_id

      handler.mobile_phone_number = "ABC123"
      unique_id_2 = handler.unique_id

      expect(unique_id_1).to eq(unique_id_2)
    end

    it "hashes the phone number" do
      handler.mobile_phone_number = "654987321"
      unique_id = handler.unique_id

      expect(unique_id).not_to include(handler.mobile_phone_number)
    end
  end

  describe "when validating the code from the user" do
    context "when a phone code was sent" do
      let(:generated_code) { "ANYc0d3" }
      let!(:phone_code) do
        Decidim::Verifications::SmsDirect::PhoneCode.create!(organization: user.organization, phone_number: SmsDirectHandler.normalize_phone_number(mobile_phone_number), code: generated_code)
      end

      context "when the code is the same" do
        let(:verification_code) { generated_code }

        it { is_expected.to be_valid }
      end

      context "when there is a PhoneCode but the given code is different" do
        let(:verification_code) { "FAILINGc0d3" }

        it { is_expected.to be_invalid }
      end
    end

    context "when there is no PhoneCode in the DB" do
      it "is invalid with an empty code" do
        expect(handler).to be_invalid
      end

      context "with any code" do
        let(:verification_code) { "Otherc0d3" }

        it { is_expected.to be_invalid }
      end
    end
  end
end
