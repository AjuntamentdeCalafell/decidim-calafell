# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module SmsVerificator
    # Census have no public app (see AdminEngine)
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::SmsVerificator

      routes do
        post "send_code/:mobile_phone_number", to: "sms_verificator#send_code"
        post "create/:verification_code", to: "sms_verificator#create"
      end

      # initializer "decidim_sms_verificator.add_authorization_handlers" do |_app|
      #   Decidim::Verifications.register_workflow(:sms_verificator) do |workflow|
      #     workflow.form = "SmsVerificatorHandler"
      #   end
      # end

      # initializer 'sms_verificator.mount_routes' do |_app|
      #   Decidim::Core::Engine.routes do
      #     mount Decidim::SmsVerificator::Engine => '/sms_verificator', as: "decidim_sms_verificator"
      #   end
      # end
    end
  end
end
