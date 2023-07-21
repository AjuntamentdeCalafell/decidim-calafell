# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module SmsVerifier
    # Census have no public app (see AdminEngine)
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::SmsVerifier

      routes do
        post "send_code/:mobile_phone_number", to: "sms_verifier#send_code"
        post "create/:verification_code", to: "sms_verifier#create"
      end

      initializer "decidim_sms_verifier.add_authorization_handlers" do |_app|
        Decidim::Verifications.register_workflow(:sms_verifier) do |workflow|
          workflow.form = "SmsVerifierHandler"
        end
      end

      # initializer 'sms_verifier.mount_routes' do |_app|
      #   Decidim::Core::Engine.routes do
      #     mount Decidim::SmsVerifier::Engine => '/sms_verifier', as: "decidim_sms_verifier"
      #   end
      # end
    end
  end
end
