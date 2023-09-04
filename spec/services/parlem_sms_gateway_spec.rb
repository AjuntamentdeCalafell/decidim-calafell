# coding: utf-8
# frozen_string_literal: true
require "rails_helper"

describe ParlemSmsGateway do
  let(:subject) { gateway }
  let(:gateway) { described_class.new(mobile_phone_number, code: code) }
  let(:mobile_phone_number) { "600102030" }
  let(:code) { "123456" }

  context "with a valid response" do
    before do
      msg_str= %Q[{"data":{"configuration_id":32399961,"id":32399961,"name":"#2","message":"TEST message Code: 123456","price":0.052,"price_with_packs":0.052,"push_sender_name":"Aj.Calafell","route_name":"Conexi\u00f3n directa","total_messages_sent":1,"total_messages_sent_with_packs":0,"dlrs":[{"message_id":"20230824133645-9746-303088-d0a76a89-e6a5-4002-be2a-35e38d15cba0","number":"34621221948","messages_sent":1,"in_SMS_blacklist":false}],"callback_url":"","start_date":"2023-08-24 15:36:45","certified":0,"certification_callback_url":""}}]
      msg_json= JSON.parse(msg_str)

      allow(gateway)
        .to receive(:perform_request)
        .and_return(msg_json)
    end

    describe "deliver_code" do
      it "returns true" do
        expect(subject.deliver_code).to be_truthy
      end
    end

    describe "text" do
      it "builds a meaningful text" do
        expect(subject.text).to eq("Your code to be verified at Decidim Calafell is: 123456")
      end
    end
  end

  context "with an invalid response" do
    before do
      error_str= %Q[{"error":{"code":"FORBIDDEN","http_code":403,"message":"Forbidden: This method must be called from customer account"}}]
      error_json= JSON.parse(error_str)

      allow(gateway)
        .to receive(:perform_request)
        .and_return(error_json)
    end

    describe "deliver_code" do
      it "returns false" do
        expect(subject.deliver_code).to be_falsey
      end
    end
  end
end
