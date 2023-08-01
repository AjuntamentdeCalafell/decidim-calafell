# frozen_string_literal: true

require 'spec_helper'
require 'decidim/dev/test/authorization_shared_examples'

describe SmsDirectHandler do
  let(:subject) { handler }
  let(:handler) { described_class.from_params(params) }
  let(:mobile_phone_number) { '666778899' }
  let(:verification_code) { nil }
  let(:params) do
    {
      mobile_phone_number: mobile_phone_number,
      verification_code: verification_code
    }
  end
  let(:user) { create(:user) }

  class FailingGateway
    def initialize(number, code); end
    def deliver_code
      false
    end
  end

  before do
    handler.user = user
  end

  context 'when sending the SMS code' do
    it_behaves_like 'an authorization handler'

    before do
      handler.valid?
    end

    describe 'mobile_phone_number' do
      context "when it isn't present" do
        let(:mobile_phone_number) { nil }

        it "should raise error" do
          expect(handler.errors.keys).to include(:mobile_phone_number)
        end
      end

      context 'with an invalid format' do
        let(:mobile_phone_number) { '-----' }

        it "should raise error" do
          expect(handler.errors.keys).to include(:mobile_phone_number)
        end
      end
    end

    describe 'verification_code' do
      context "when sending the SMS fails" do
        let(:verification_code) { nil }

        before do
          @previous_gateway= Decidim.sms_gateway_service
          Decidim.sms_gateway_service= FailingGateway.name
        end
        after do
          Decidim.sms_gateway_service= @previous_gateway
        end

        it { is_expected.not_to be_valid }
      end

      context 'when sending the SMS succeeds' do
        it { is_expected.to be_invalid }
      end
    end

  end

  context 'unique_id' do
    it 'generates a different ID for a different phone number' do
      handler.mobile_phone_number = 'ABC123'
      unique_id1 = handler.unique_id

      handler.mobile_phone_number = 'XYZ456'
      unique_id2 = handler.unique_id

      expect(unique_id1).to_not eq(unique_id2)
    end

    it 'generates the same ID for the same phone number' do
      handler.mobile_phone_number = 'ABC123'
      unique_id1 = handler.unique_id

      handler.mobile_phone_number = 'ABC123'
      unique_id2 = handler.unique_id

      expect(unique_id1).to eq(unique_id2)
    end

    it 'hashes the phone number' do
      handler.mobile_phone_number = 'ABC123'
      unique_id = handler.unique_id

      expect(unique_id).to_not include(handler.mobile_phone_number)
    end
  end

  describe "when validating the code from the user" do
    let(:verification_code) { "ANYc0d3"}

    context "when a pending authorization exists" do
      let!(:authorization) do
        Decidim::Authorization.create!(user: user, name: "sms_direct", metadata: handler.verification_metadata)
      end 
        
      context "when the code is the same" do
        it { is_expected.to be_valid }        
      end

      context "when the code is different" do
        it "should be invalid" do
          handler.verification_code= "FAILINGc0d3"

          expect(handler).to be_invalid
        end
      end
    end

    context "when there is no authorization for the current user" do
      it { is_expected.to be_invalid }
    end
  end
end
