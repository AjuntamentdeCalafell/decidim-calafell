# frozen_string_literal: true

Decidim.configure do |config|
  config.application_name = Rails.application.secrets.decidim[:application_name]
  config.mailer_sender = Rails.application.secrets.decidim[:mailer_sender]

  # Sets the list of available locales for the whole application.
  #
  # When an organization is created through the System area, system admins will
  # be able to choose the available languages for that organization. That list
  # of languages will be equal or a subset of the list in this file.
  # config.available_locales = Rails.application.secrets.decidim[:available_locales].presence || [:en]
  # Or block set it up manually and prevent ENV manipulation:
  config.available_locales = %w(ca es)
  
  # Sets the default locale for new organizations. When creating a new
  # organization from the System area, system admins will be able to overwrite
  # this value for that specific organization.
  config.default_locale = Rails.application.secrets.decidim[:default_locale].presence || :ca

  # Custom HTML Header snippets
  #
  # The most common use is to integrate third-party services that require some
  # extra JavaScript or CSS. Also, you can use it to add extra meta tags to the
  # HTML. Note that this will only be rendered in public pages, not in the admin
  # section.
  #
  # Before enabling this you should ensure that any tracking that might be done
  # is in accordance with the rules and regulations that apply to your
  # environment and usage scenarios. This component also comes with the risk
  # that an organization's administrator injects malicious scripts to spy on or
  # take over user accounts.
  #
  config.enable_html_header_snippets = Rails.application.secrets.decidim[:enable_html_header_snippets].present?

  # Allow organizations admins to track newsletter links.
  config.track_newsletter_links = Rails.application.secrets.decidim[:track_newsletter_links].present? unless Rails.application.secrets.decidim[:track_newsletter_links] == "auto"

  # Map and Geocoder configuration
  config.maps = {
    provider: :here,
    api_key: Rails.application.secrets.maps[:api_key],
    static: { url: "https://image.maps.ls.hereapi.com/mia/1.6/mapview" }
  }

  config.geocoder = {
    timeout: 5,
    units: :km
  }

  # Workaround to enable SVG assets cors
  # config.cors_enabled = Rails.application.secrets.decidim[:cors_enabled].present?

  # Max requests in a time period to prevent DoS attacks. Only applied on production.
  config.throttling_max_requests = Rails.application.secrets.decidim[:throttling_max_requests].to_i

  # Time window in which the throttling is applied.
  config.throttling_period = Rails.application.secrets.decidim[:throttling_period].to_i.minutes

  config.follow_http_x_forwarded_host = Rails.application.secrets.decidim[:follow_http_x_forwarded_host].present?

  # Custom resource reference generator method
  # config.resource_reference_generator = lambda do |resource, feature|
  #   # Implement your custom method to generate resources references
  #   "1234-#{resource.id}"
  # end

  # Currency unit
  # config.currency_unit = "€"

  # The number of reports which an object can receive before hiding it
  # config.max_reports_before_hiding = 3

  # Custom HTML Header snippets
  #
  # The most common use is to integrate third-party services that require some
  # extra JavaScript or CSS. Also, you can use it to add extra meta tags to the
  # HTML. Note that this will only be rendered in public pages, not in the admin
  # section.
  #
  # Before enabling this you should ensure that any tracking that might be done
  # is in accordance with the rules and regulations that apply to your
  # environment and usage scenarios. This feature also comes with the risk
  # that an organization's administrator injects malicious scripts to spy on or
  # take over user accounts.
  #
  config.enable_html_header_snippets = false

  if ENV['HEROKU_APP_NAME'].present?
    config.base_uploads_path = ENV['HEROKU_APP_NAME'] + '/'
  end

  config.sms_gateway_service = "SmsGateway" if Rails.application.secrets.sms.values.all?(&:present?)
end

# Inform Decidim about the assets folder
Decidim.register_assets_path File.expand_path("app/packs", Rails.application.root)

Decidim::Verifications.register_workflow(:census_authorization_handler) do |auth|
  auth.form = 'CensusAuthorizationHandler'
  auth.options do |options|
    options.attribute :postal_code, type: :string, required: false
  end
end

Rails.application.config.i18n.available_locales = Decidim.available_locales
Rails.application.config.i18n.default_locale = Decidim.default_locale

# Inform Decidim about the assets folder
Decidim.register_assets_path File.expand_path("app/packs", Rails.application.root)