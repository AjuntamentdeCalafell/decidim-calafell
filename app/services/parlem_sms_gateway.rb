# frozen_string_literal: true

# A Service to send SMS to Calafell's provider so users can be verified by SMS.
class ParlemSmsGateway
  attr_reader :mobile_phone_number, :code

  def initialize(mobile_phone_number, code)
    @mobile_phone_number = mobile_phone_number
    @code = code
  end

  def deliver_code
    true
    # if response[:error].present?
    #   report_error
    #   false
    # else
    #   true
    # end
  end

  def response
    return @response if defined?(@response)

    # POST https://api.sms.parlem.com/v1/push/simple

    # parlem_base_url = https://api.sms.parlem.com/v1
    # TODO: WS to send SMS with parlem

    return true
    # connection = Faraday.new("#{Rails.application.secrets.sms.fetch(:parlem_base_url)}/push/simple")
    # response = connection.post do |request|
    #   request.body = request_body
    # end

    # @response ||= Nokogiri::XML(response.body).remove_namespaces!
  end

  def text
    I18n.t("decidim.sms.text", code: code)
  end

  private

  def report_error
    return unless defined?(Raven)

    Raven.capture_message("Error while sending an SMS: #{response.to_s}")
  end

  def request_body
    {
      configuration_name: "nombre_api",
      message: "Código de verificación por SMS: #{code}",
      numbers: "34#{mobile_phone_number}"
    }
  end
end
