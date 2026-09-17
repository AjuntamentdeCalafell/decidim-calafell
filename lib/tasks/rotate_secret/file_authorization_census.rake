# frozen_string_literal: true

module RotateFileAuthorizationHandlerCensus
  module_function

  HANDLER_NAMES = %w(file_authorization_handler ephemeral_file_authorization_handler).freeze unless const_defined?(:HANDLER_NAMES)

  def run!
    options = options_from_env!
    organization = find_organization!(options[:organization_id])
    csv_data = load_csv_data!(options[:csv_path])

    existing_census_count = Decidim::FileAuthorizationHandler::CensusDatum.inside(organization).count
    existing_authorizations_count = authorization_scope(organization).count

    if options[:dry_run]
      summary_data = {
        organization_id: organization.id,
        parsed: csv_data.values.count,
        invalid: csv_data.errors.count,
        existing_census: existing_census_count,
        inserted: csv_data.values.count,
        removed_authorizations: options[:reset_authorizations] ? existing_authorizations_count : 0,
        reset_authorizations: options[:reset_authorizations]
      }

      print_summary(
        dry_run: true,
        summary: summary_data
      )
      return
    end

    removed_authorizations = 0

    ActiveRecord::Base.transaction do
      Decidim::FileAuthorizationHandler::CensusDatum.clear(organization)
      # rubocop:disable Rails/SkipsModelValidations
      Decidim::FileAuthorizationHandler::CensusDatum.insert_all(organization, csv_data.values, csv_data.headers[2..])
      # rubocop:enable Rails/SkipsModelValidations
      Decidim::FileAuthorizationHandler::RemoveDuplicatesJob.new.perform(organization)

      removed_authorizations = authorization_scope(organization).delete_all if options[:reset_authorizations]
    end

    inserted_count = Decidim::FileAuthorizationHandler::CensusDatum.inside(organization).count

    summary_data = {
      organization_id: organization.id,
      parsed: csv_data.values.count,
      invalid: csv_data.errors.count,
      existing_census: existing_census_count,
      inserted: inserted_count,
      removed_authorizations: removed_authorizations,
      reset_authorizations: options[:reset_authorizations]
    }

    print_summary(
      dry_run: false,
      summary: summary_data
    )
  end

  def options_from_env!
    organization_id = ENV.fetch("ORGANIZATION_ID", nil)
    csv_path = ENV.fetch("CSV_PATH", nil)

    abort "Set ORGANIZATION_ID before running this task" if organization_id.blank?
    abort "Set CSV_PATH before running this task" if csv_path.blank?

    {
      organization_id: Integer(organization_id),
      csv_path: csv_path,
      dry_run: ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", "false")),
      reset_authorizations: ActiveModel::Type::Boolean.new.cast(ENV.fetch("RESET_AUTHORIZATIONS", "false"))
    }
  rescue ArgumentError
    abort "ORGANIZATION_ID must be an integer"
  end

  def find_organization!(organization_id)
    Decidim::Organization.unscoped.find(organization_id)
  rescue ActiveRecord::RecordNotFound
    abort "Organization #{organization_id} not found"
  end

  def load_csv_data!(csv_path)
    path = Pathname.new(csv_path)
    abort "CSV file not found: #{csv_path}" unless path.exist?
    abort "CSV_PATH must point to a .csv file" unless path.extname.casecmp(".csv").zero?

    Decidim::FileAuthorizationHandler::CsvData.new(path.to_s)
  end

  def authorization_scope(organization)
    Decidim::Authorization
      .unscoped
      .joins(:user)
      .where(name: HANDLER_NAMES)
      .where(decidim_users: { decidim_organization_id: organization.id })
  end

  def print_summary(dry_run:, summary:)
    summary = [
      "organization_id=#{summary[:organization_id]}",
      "parsed=#{summary[:parsed]}",
      "invalid=#{summary[:invalid]}",
      "existing_census=#{summary[:existing_census]}",
      "inserted=#{summary[:inserted]}",
      "removed_authorizations=#{summary[:removed_authorizations]}",
      "reset_authorizations=#{summary[:reset_authorizations]}"
    ].join(", ")

    puts "File authorization census rebuild#{" (dry run)" if dry_run}: #{summary}"
  end
end

namespace :rotate_secret do
  desc "Rebuild file_authorization_handler census from CSV using the current SECRET_KEY_BASE"
  task file_census: :environment do
    RotateFileAuthorizationHandlerCensus.run!
  end
end
