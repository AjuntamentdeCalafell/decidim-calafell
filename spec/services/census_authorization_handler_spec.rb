# frozen_string_literal: true

require "rails_helper"
require "decidim/dev/test/authorization_shared_examples"

describe CensusAuthorizationHandler do
  subject { handler }

  let(:handler) { described_class.from_params(params) }
  let(:document_number) { "123456789Z" }
  let(:document_type_id) do
    index = [:dni, :passport, :nie, :community_dni].index(document_type)
    (index + 1).to_s if index
  end
  let(:document_type) { :nie }
  let(:date_of_birth) { Date.civil(1969, 2, 23) }
  let(:postal_code) { "43820" }
  let(:params) do
    {
      document_number:,
      document_type:,
      date_of_birth:,
      postal_code:
    }
  end

  let(:response) do
    { valid: true }
  end

  before do
    handler.user = create(:user)
    stub_request(:get, %r{example.net/census/url})
      .with(
        query: {
          postal_code:,
          auth_token: "secret",
          document_type: document_type_id,
          birth_date: date_of_birth&.strftime("%Y-%m-%d"),
          document_number:
        }
      )
      .to_return(
        status: 200,
        body: response.to_json,
        headers: {
          "Content-Type" => "application/json"
        }
      )
  end

  context "with a valid response" do
    it_behaves_like "an authorization handler"

    describe "document_number" do
      context "when it isn't present" do
        let(:document_number) { nil }

        it { is_expected.not_to be_valid }
      end

      context "with an invalid format" do
        let(:document_number) { "-----" }

        it { is_expected.not_to be_valid }
      end
    end

    describe "document_type" do
      context "when it isn't present" do
        let(:document_type) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when it has a weird value" do
        let(:document_type) { :driver_license }

        it { is_expected.not_to be_valid }
      end
    end

    describe "postal_code" do
      context "when it isn't present" do
        let(:postal_code) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when it has a weird value" do
        let(:postal_code) { "ABCDE" }

        it { is_expected.not_to be_valid }
      end
    end

    describe "date_of_birth" do
      context "when it isn't present" do
        let(:date_of_birth) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when it's under 16" do
        let(:date_of_birth) { 15.years.ago }

        it { is_expected.not_to be_valid }
      end

      context "when data from a date field is provided" do
        let(:params) do
          {
            "date_of_birth(1i)" => "2010",
            "date_of_birth(2i)" => "8",
            "date_of_birth(3i)" => "16"
          }
        end

        let(:date_of_birth) { nil }

        it "correctly parses the date" do
          expect(subject.date_of_birth.year).to eq(2010)
          expect(subject.date_of_birth.month).to eq(8)
          expect(subject.date_of_birth.day).to eq(16)
        end
      end
    end

    context "when everything is fine" do
      it { is_expected.to be_valid }
    end
  end

  describe "unique_id" do
    it "generates a different ID for a different document number" do
      handler.document_number = "ABC123"
      unique_id_1 = handler.unique_id

      handler.document_number = "XYZ456"
      unique_id_2 = handler.unique_id

      expect(unique_id_1).not_to eq(unique_id_2)
    end

    it "generates the same ID for the same document number" do
      handler.document_number = "ABC123"
      unique_id_1 = handler.unique_id

      handler.document_number = "ABC123"
      unique_id_2 = handler.unique_id

      expect(unique_id_1).to eq(unique_id_2)
    end

    it "hashes the document number" do
      handler.document_number = "ABC123"
      unique_id = handler.unique_id

      expect(unique_id).not_to include(handler.document_number)
    end
  end

  context "with an invalid response" do
    let(:response) do
      { valid: false }
    end

    it { is_expected.not_to be_valid }
  end
end
