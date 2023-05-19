# frozen_string_literal: true

module Decidim
  module FileAuthorizationHandler
    class RemoveDuplicatesJob < ApplicationJob
      queue_as :default

      def perform(organization)
        duplicated_census(organization).pluck(:id_document).each do |id_document|
          CensusDatum.inside(organization)
                     .where(id_document: id_document)
                     .order(id: :desc)
                     .all[1..]
                     .each(&:delete)
        end
      end

      private

      def duplicated_census(organization)
        CensusDatum.inside(organization)
                   .select(:id_document)
                   .group(:id_document)
                   .having("count(id_document)>1")
      end
    end
  end
end
