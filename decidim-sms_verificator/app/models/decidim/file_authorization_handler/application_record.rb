# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
