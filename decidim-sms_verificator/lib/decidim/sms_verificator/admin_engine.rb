# frozen_string_literal: true

module Decidim
  module SmsVerificator
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::SmsVerificator::Admin

      routes do
      end
    end
  end
end
