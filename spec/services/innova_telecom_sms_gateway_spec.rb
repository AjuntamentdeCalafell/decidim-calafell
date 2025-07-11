# frozen_string_literal: true

require "rails_helper"

describe InnovaTelecomSmsGateway do
  subject { gateway }

  let(:gateway) { described_class.new(mobile_phone_number, code) }
  let(:mobile_phone_number) { "600102030" }
  let(:code) { "123456" }

  context "with a valid response" do
    before do
      allow(gateway)
        .to receive(:response)
        .and_return(Nokogiri::XML("<?xml version=\"1.0\" encoding=\"UTF-8\"?><soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><soapenv:Body><enviosms2Response xmlns=\"http://envios.rbs.innovatelecom.org\"><enviosms2Return>&lt;ResultadoOp&gt;
  &lt;estado&gt;OK&lt;/estado&gt;
  &lt;codigo&gt;OK&lt;/codigo&gt;
  &lt;detalle&gt;Operaci&#xF3;n realizada con &#xE9;xito&lt;/detalle&gt;
  &lt;identificador&gt;Switch_RBS4SMS_MT_9d2d42d4a8f845e48c6f5fc20d589bba&lt;/identificador&gt;
&lt;/ResultadoOp&gt;</enviosms2Return></enviosms2Response></soapenv:Body></soapenv:Envelope>"))
    end

    describe "deliver_code" do
      it "returns true" do
        expect(subject.deliver_code).to be_truthy
      end
    end

    describe "text" do
      it "builds a meaningful text" do
        expect(subject.text).to eq("Your code to be verified at Decidim Calafell is: 123456")
      end
    end
  end

  context "with an invalid response" do
    before do
      allow(gateway)
        .to receive(:response)
        .and_return(Nokogiri::XML("<?xml version=\"1.0\" encoding=\"UTF-8\"?><soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"><soapenv:Body><enviosms2Response xmlns=\"http://envios.rbs.innovatelecom.org\"><enviosms2Return>&lt;ResultadoOp&gt;
  &lt;estado&gt;NOK&lt;/estado&gt;
  &lt;codigo&gt;OK&lt;/codigo&gt;
  &lt;detalle&gt;Operaci&#xF3;n realizada con &#xE9;xito&lt;/detalle&gt;
  &lt;identificador&gt;Switch_RBS4SMS_MT_9d2d42d4a8f845e48c6f5fc20d589bba&lt;/identificador&gt;
&lt;/ResultadoOp&gt;</enviosms2Return></enviosms2Response></soapenv:Body></soapenv:Envelope>"))
    end

    describe "deliver_code" do
      it "returns false" do
        expect(subject.deliver_code).to be_falsey
      end
    end
  end
end
