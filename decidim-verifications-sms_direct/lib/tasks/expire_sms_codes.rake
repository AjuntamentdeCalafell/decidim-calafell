# frozen_string_literal: true

namespace :sms_direct do
  desc "This job removes all expired SMS codes from all organizations"
  task clean_expired_codes: :environment do
    puts "SMS codes before expiring: #{Decidim::Verifications::SmsDirect::PhoneCode.count}"
    Decidim::Verifications::SmsDirect::PhoneCode.clear_expired
    puts "SMS codes after expiring: #{Decidim::Verifications::SmsDirect::PhoneCode.count}"
  end
end
