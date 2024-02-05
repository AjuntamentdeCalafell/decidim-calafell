every 1.day, at: "2:00 am" do
  rake "decidim:open_data:export"
end

every 1.day, at: "3:00 am" do
  rake "sms_direct:clean_expired_codes"
end

every 1.day, at: "4:00 am" do
  rake "decidim:metrics:all"
end
