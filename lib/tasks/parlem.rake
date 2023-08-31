# frozen_string_literal: true

namespace :parlem do
  desc <<~EODESC
    Sends an SMS fake code or message to the given phone number (with 34 prefix)
  EODESC
  task :send_sms, [:number, :msg] => :environment do |_task, args|
    mobile_phone_number= args.number
    msg= args.msg.presence || "Code is TEST_CODE"

    sms_gateway= Decidim.sms_gateway_service.to_s.constantize
    success= sms_gateway.new(mobile_phone_number, message: msg).deliver_code
    puts "Sending SMS success? #{success}"
    puts "(see the log for more details)" unless success
  end
end
