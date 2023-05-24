# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module SmsVerificator
    # Census have no public app (see AdminEngine)
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::SmsVerificator

      routes do
        # Add engine routes here
        get "send_code/:mobile_phone_number", to: "sms_verificator#send_code"
      end

      initializer "decidim_sms_verificator.add_authorization_handlers" do |_app|
        Decidim::Verifications.register_workflow(:sms_verificator) do |workflow|
          workflow.form = "SmsVerificatorHandler"
        end
      end
    end
  end
end
