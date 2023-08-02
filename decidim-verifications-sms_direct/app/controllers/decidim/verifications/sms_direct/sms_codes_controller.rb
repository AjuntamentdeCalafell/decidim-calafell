module Decidim
  module Verifications
  module SmsDirect
      class SmsCodesController < ApplicationController
        skip_before_action :verify_authenticity_token

        # 
        def create
          phone_num = params[:phone_num]

          handler = ::SmsDirectHandler.from_params({mobile_phone_number: phone_num, user: current_user})
          handler.generate_and_send_code
          metadata = handler.verification_metadata

          phone_code= Decidim::Verifications::SmsDirect::PhoneCode.find_or_initialize_by(
            organization: current_organization,
            phone_number: phone_num
          )
          phone_code.code = metadata[:verification_code]

          if phone_code.save
            render json: { phone_number: phone_code.phone_number }
          else
            render json: { error: phone_code.full_messages }
          end
        end
      end
    end
  end
end
