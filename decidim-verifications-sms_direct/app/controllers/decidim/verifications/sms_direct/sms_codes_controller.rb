module Decidim
  module Verifications
    class SmsCodesController < ApplicationController
      skip_before_action :verify_authenticity_token

      def send_code
        phone_num = params[:phone_num]

        sms_gateway.new(mobile_phone_number, generated_code).deliver_code

        handler = ::SmsDirectHandler.from_params({mobile_phone_number: phone_num})
        handler.verification_code
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
          name: "sms_direct"
        )
      end

      def sms_gateway
        Decidim.sms_gateway_service.to_s.constantize
      end

    end
  end
end

