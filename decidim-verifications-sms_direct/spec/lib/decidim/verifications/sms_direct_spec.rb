# frozen_string_literal: true

require 'spec_helper'

describe Decidim::Verifications::SmsDirect do

  describe "workflow" do
    let(:workflow) { Decidim.authorization_workflows.find {|wf| wf.name == "sms_direct"} }

    it "is initialized" do
      expect(workflow).to be_present
    end

    it "is configured with the handler" do
      expect(workflow.form).to eq("SmsDirectHandler")
      expect(SmsDirectHandler.class).to be_present
    end

    it "is of type direct" do
      expect(workflow.type).to eq("direct")
    end
  end
end
