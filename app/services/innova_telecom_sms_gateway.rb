# frozen_string_literal: true

# A Service to send SMS to Calafell's provider so users can be verified by SMS.
class InnovaTelecomSmsGateway
  attr_reader :mobile_phone_number, :code

  def initialize(mobile_phone_number, code)
    @mobile_phone_number = mobile_phone_number
    @code = code
  end

  def deliver_code
    if response.xpath("//Fault").present? || response.to_s.include?("NOK")
      report_error
      false
    else
      true
    end
  end

  def response
    return @response if defined?(@response)

    connection = Faraday.new(Rails.application.secrets.sms.fetch(:service_url))
    response = connection.post do |request|
      request.headers["SOAPAction"] = ""
      request.headers["Content-Type"] = "text/xml"
      request.body = request_body
    end

    @response ||= Nokogiri::XML(response.body).remove_namespaces!
  end

  def text
    I18n.t("decidim.sms.text", code:)
  end

  private

  def report_error
    return unless defined?(Raven)

    Raven.capture_message("Error while sending an SMS: #{response}")
  end

  def request_body
    @request_body ||= <<~EORB
      <?xml version="1.0" standalone="no"?>
          <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:env="http://envios.rbs.innovatelecom.org">
           <soapenv:Body>
              <env:enviosms2>
                 <env:sCodigoCuenta>#{Rails.application.secrets.sms.fetch(:username)}</env:sCodigoCuenta>
                 <env:sClaveCuenta>#{Rails.application.secrets.sms.fetch(:password)}</env:sClaveCuenta>
                 <env:sCodigoCanal>#{Rails.application.secrets.sms.fetch(:service_id)}</env:sCodigoCanal>
                 <env:sNumeroDestino>#{mobile_phone_number}</env:sNumeroDestino>
                 <env:sContenido>#{text}</env:sContenido>
                 <env:iPermanencia>10000</env:iPermanencia>
                 <env:bEmergente>0</env:bEmergente>
                 <env:bAcuse>0</env:bAcuse>
              </env:enviosms2>
             </soapenv:Body>
          </soapenv:Envelope>
    EORB
  end
end
