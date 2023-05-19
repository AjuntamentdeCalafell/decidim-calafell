# frozen_string_literal: true

module Decidim
  module SmsVerificator
    # Census have no public app (see AdminEngine)
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::SmsVerificator

      initializer "decidim_sms_verificator.add_authorization_handlers" do |_app|
        Decidim::Verifications.register_workflow(:sms_verificator) do |workflow|
          workflow.form = "SmsVerificatorHandler"
        end
      end
    end
  end
end
