module Decidim
  module Verifications
  module SmsDirect
      class SmsCodesController < ApplicationController
        skip_before_action :verify_authenticity_token

        # def send_code
        def create
          phone_num = params[:phone_num]

          handler = ::SmsDirectHandler.from_params({mobile_phone_number: phone_num, user: current_user})
          metadata = handler.verification_metadata

          authorization.metadata = metadata
          authorization.save!

          render json: { metadata: metadata }
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
end
