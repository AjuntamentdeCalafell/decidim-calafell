# frozen_string_literal: true

module Decidim::Initiatives::VoteFormDecorator
  def self.decorate
    Decidim::Initiatives::VoteForm.class_eval do
      alias_method :authorization_handler_original, :authorization_handler

      def authorization_handler
        handler = authorization_handler_original
        handler.user = signer

        handler
      end
    end
  end
end

::Decidim::Initiatives::VoteFormDecorator.decorate
