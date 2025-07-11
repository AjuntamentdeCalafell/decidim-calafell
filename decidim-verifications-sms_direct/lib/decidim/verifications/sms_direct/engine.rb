# frozen_string_literal: true

require "rails"
require "decidim/core"

module Decidim
  module Verifications
    module SmsDirect
      # Census have no public app (see AdminEngine)
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::SmsDirect

        routes do
          post "sms_codes", to: "sms_codes#create"
        end

        # Won't start if the sms gateway is not set.
        # As initializers are executed by aphabetical order this one starts with zzz to be the last.
        initializer "zzz.verifiers_sms_direct.has_sms_gateway" do
          Decidim.sms_gateway_service.to_s.constantize
        end

        initializer "verifiers_sms_direct.add_authorization_handlers" do |_app|
          Decidim::Verifications.register_workflow(:sms_direct) do |workflow|
            workflow.form = "SmsDirectHandler"
          end
        end

        initializer "verifiers_sms_direct.mount_routes" do |_app|
          Decidim::Core::Engine.routes do
            mount Decidim::Verifications::SmsDirect::Engine => "/verifications_sms_direct", as: "decidim_verifications_sms_direct"
          end
        end
      end
    end
  end
end
