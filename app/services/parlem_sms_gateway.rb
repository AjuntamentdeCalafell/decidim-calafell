# frozen_string_literal: true

# A Service to send SMS to Calafell's provider so users can be verified by SMS.
class ParlemSmsGateway
  attr_reader :mobile_phone_number, :code

  # param +to_send+: A named parameter, either code or message. I.e.: `code: "TEST_code"` or `message: "whatever to say`
  def initialize(mobile_phone_number, to_send)
    @mobile_phone_number = mobile_phone_number.sub("+", "")
    @message = to_send[:message]
    @code = to_send[:code]
    @parlem_config= Rails.application.secrets.sms[:parlem]
  end

  def deliver_code
    raise "Nothing to send!" unless @message.present? || @code.present?

    response= perform_request

    if response["error"].present?
      report_error(response)
      false
    else
      Rails.logger.info("SMS sent with msg id: #{response.dig('data', 'id')}")
      true
    end
  end

  # POST to Parlem's push/simple endpoint
  def perform_request
    parlem_api_url = "#{@parlem_config[:service_url]}/push/simple"

    connection = Faraday.new(url: @parlem_config[:service_url]) do |builder|
      builder.request :url_encoded
      builder.response :json
    end

    response = connection.post(parlem_api_url,
      configuration_name: @parlem_config[:configuration_name],
      message: @message || text,
      numbers: @mobile_phone_number,
      api_token: @parlem_config[:api_token]
    )

    response.body
  end

  def text
    I18n.t("decidim.sms.text", code: @code)
  end

  #-------------------------------------------
  private
  #-------------------------------------------

  def report_error(response)
    Rails.logger.error("SMS failed: #{response}")
  end
end
