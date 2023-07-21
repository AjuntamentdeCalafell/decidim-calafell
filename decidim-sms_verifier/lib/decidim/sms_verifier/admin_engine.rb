# frozen_string_literal: true

module Decidim
  module SmsVerifier
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::SmsVerifier::Admin

      routes do
      end
    end
  end
end
