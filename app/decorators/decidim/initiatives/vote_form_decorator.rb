# frozen_string_literal: true

module Decidim::Initiatives::VoteFormDecorator
  def self.decorate
    Decidim::Initiatives::VoteFormDecorator.class_eval do
      def authorization_handler
        return unless document_number && handler_name

        @authorization_handler ||= Decidim::AuthorizationHandler.handler_for(handler_name,
                                                                            user: signer, # Send user to authorization handler
                                                                            document_number: document_number,
                                                                            name_and_surname: name_and_surname,
                                                                            date_of_birth: date_of_birth,
                                                                            postal_code: postal_code)
      end
    end
  end
end

::Decidim::Initiatives::VoteFormDecorator.decorate
