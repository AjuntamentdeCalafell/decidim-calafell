# frozen_string_literal: true

# Checks the authorization against the census for Terrassa.
require 'digest/md5'

# This class performs a check against the official census database in order
# to verify the citizen's residence.
class CensusAuthorizationHandler < Decidim::AuthorizationHandler
  include ActionView::Helpers::SanitizeHelper
  include Virtus::Multiparams

  attribute :document_number, String
  attribute :postal_code, String
  attribute :document_type, Symbol
  attribute :date_of_birth, Date

  validates :date_of_birth, :postal_code, presence: true
  validates :document_type, inclusion: { in: %i[dni nie passport community_dni] }, presence: true
  validates :document_number, format: { with: /\A[A-z0-9]*\z/ }, presence: true

  validate :document_type_valid
  validate :over_16

  def census_document_types
    %i[dni nie passport community_dni].map do |type|
      [I18n.t(type, scope: 'decidim.census_authorization_handler.document_types'), type]
    end
  end

  def unique_id
    Digest::MD5.hexdigest(
      "#{document_number}-#{Rails.application.secrets.secret_key_base}"
    )
  end

  def metadata
    super.merge(district: district) if district.present?
  end

  private

  def district
    response.xpath('//districte').text.to_s
  end

  def sanitized_document_type
    case document_type&.to_sym
    when :dni
      1
    when :passport
      2
    when :nie
      3
    when :community_dni
      4
    end
  end

  def sanitized_date_of_birth
    @sanitized_date_of_birth ||= date_of_birth&.strftime('%Y-%m-%d')
  end

  def document_type_valid
    return nil if response.blank?

    errors.add(:document_number, I18n.t('census_authorization_handler.invalid_document')) unless response['valid'] == true
  end

  def response
    return nil if document_number.blank? ||
                  document_type.blank? ||
                  date_of_birth.blank?

    return @response if defined?(@response)

    response ||= Faraday.get Rails.application.secrets.census_url do |request|
      request.params['auth_token'] = Rails.application.secrets.census_auth_token
      request.params['document_type'] = sanitized_document_type
      request.params['document_number'] = document_number
      request.params['postal_code'] = postal_code
      request.params['birth_date'] = sanitized_date_of_birth
    end

    @response ||= JSON.parse(response.body)
  end

  def over_16
    errors.add(:date_of_birth, I18n.t('census_authorization_handler.age_under_16')) unless age && age >= 16
  end

  def age
    return nil if date_of_birth.blank?

    now = Date.current
    extra_year = (now.month > date_of_birth.month) || (
      now.month == date_of_birth.month && now.day >= date_of_birth.day
    )

    now.year - date_of_birth.year - (extra_year ? 0 : 1)
  end
end
