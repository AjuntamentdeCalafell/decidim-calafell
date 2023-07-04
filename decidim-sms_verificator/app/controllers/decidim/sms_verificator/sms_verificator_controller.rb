module Decidim
  module SmsVerificator
    class SmsVerificatorController < ApplicationController
      skip_before_action :verify_authenticity_token

      def send_code
        mobile_phone_number = params[:mobile_phone_number]
        
        handler = Decidim::Verifications::Sms::MobilePhoneForm.from_params(params.merge(handler_name: "sms_verificator"))
        
        metadata = handler.verification_metadata

        authorization.metadata = metadata
        authorization.save

        render json: { metadata: metadata }
      end

      def create
        byebug
        @form = MobilePhoneForm.from_params(params.merge(user: current_user))

        PerformAuthorizationStep.call(authorization, @form)
      end

      private

      def authorization
        @authorization ||= Decidim::Authorization.find_or_initialize_by(
          user: current_user,
          name: "sms_verificator"
        )
      end
    end
  end
end

