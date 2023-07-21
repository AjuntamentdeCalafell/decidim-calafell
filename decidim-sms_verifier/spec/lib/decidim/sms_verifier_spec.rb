# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Decidim::SmsVerifier do

  describe "workflow" do
    let(:workflow) { Decidim.authorization_workflows.find {|wf| wf.name == "sms_verifier"} }

    it "is initialized" do
      expect(workflow).to be_present
    end

    it "is conigured with the handler" do
      expect(workflow.form).to eq("SmsVerifierHandler")
      expect(SmsVerifierHandler.class).to be_present
    end

    it "is of type direct" do
      expect(workflow.type).to eq("direct")
    end
  end
end
