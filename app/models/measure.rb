require 'api_entity'

class Measure
  include ApiEntity

  attr_accessor :id,
                :origin,
                :import,
                :vat,
                :excise,
                :goods_nomenclature_item_id,
                :meursing,
                :resolved_duty_expression,
                :universal_waiver_applies

  attr_reader :effective_start_date,
              :effective_end_date

  has_one :geographical_area
  has_many :legal_acts
  has_one :measure_type
  has_one :suspension_legal_act, class_name: 'LegalAct'
  has_one :additional_code
  has_one :order_number
  has_one :duty_expression
  has_many :excluded_countries, class_name: 'GeographicalArea'
  has_many :measure_components
  has_many :measure_conditions
  has_many :measure_condition_permutation_groups
  has_many :footnotes
  has_one :goods_nomenclature, polymorphic: true
  has_one :preference_code

  delegate :erga_omnes?, to: :geographical_area
  delegate :amount, to: :duty_expression
  delegate :supplementary?, :safeguard?, to: :measure_type

  class << self
    def grouped_measure_types
      @grouped_measure_types ||= Rails.configuration.grouped_measure_types
    end

    def all_grouped_types
      @all_grouped_types ||= grouped_measure_types.values.flatten.sort
    end
  end

  delegate :grouped_measure_types, :all_grouped_types, to: :class

  def excluded_country_list
    countries = if exclusions_include_european_union?
                  # Replace EU members with the EU geographical_area
                  [GeographicalArea.european_union] + excluded_countries.delete_if(&:eu_member?)
                else
                  excluded_countries
                end

    countries.map(&:description).join(', ').html_safe
  end

  def exclusions_include_european_union?
    GeographicalArea.eu_members_ids.all? { |eu_member| eu_member.in?(excluded_country_ids) }
  end

  def national?
    origin == 'uk'
  end

  def vat?
    vat
  end

  def excise?
    excise
  end

  def supplementary_unit_description
    if measure_type.supplementary_unit_import_only?
      'Supplementary unit (import)'
    else
      'Supplementary unit'
    end
  end

  def unclassified?
    !classified?
  end

  def classified?
    all_grouped_types.include?(measure_type.id)
  end

  def vat_excise?
    grouped_measure_types[:vat_and_excise].include?(measure_type.id)
  end

  def suspension?
    grouped_measure_types[:suspension].include?(measure_type.id)
  end

  def credibility_check?
    grouped_measure_types[:credibility_checks].include?(measure_type.id)
  end

  def excluded?
    grouped_measure_types[:excluded].include?(measure_type.id)
  end

  def import_controls?
    grouped_measure_types[:import_controls].include?(measure_type.id)
  end

  def unclassified_import_controls?
    unclassified? && (measure_type.duties_permitted? || measure_type.duties_not_permitted?)
  end

  def trade_remedies?
    grouped_measure_types[:remedies].include?(measure_type.id)
  end

  def third_country_duties?
    grouped_measure_types[:third_country_duties].include?(measure_type.id)
  end

  def tariff_preferences?
    grouped_measure_types[:tariff_preferences].include?(measure_type.id)
  end

  def other_customs_duties?
    grouped_measure_types[:other_customs_duties].include?(measure_type.id)
  end

  def unclassified_customs_duties?
    unclassified? && measure_type.duties_mandatory?
  end

  def quotas?
    grouped_measure_types[:quotas].include?(measure_type.id)
  end

  def import?
    import
  end

  def destination
    import? ? 'import' : 'export'
  end

  def effective_start_date=(date)
    @effective_start_date = Date.parse(date) if date.present?
  end

  def effective_end_date=(date)
    @effective_end_date = Date.parse(date) if date.present?
  end

  def additional_code
    @additional_code.presence || NullObject.new(code: '')
  end

  def key
    "#{third_country_duties? ? 0 : 1}
     #{tariff_preferences? ? 0 : 1}
     #{supplementary? ? 0 : 1}
     #{vat? ? 0 : 1}
     #{excise ? 0 : 1}
     #{geographical_area.children_geographical_areas.any? ? 0 : 1}
     #{geographical_area.description}#{additional_code_sort}"
  end

  # _999 is the master additional code and should come first
  def additional_code_sort
    if additional_code && additional_code.code.to_s.include?('999')
      'A000'
    else
      additional_code.code.to_s
    end
  end

  def measure_conditions_with_guidance
    measure_conditions.select(&:has_guidance?)
  end

  def measure_type_duty_label
    I18n.t("measure_type_duties.#{geographical_area.id}.#{measure_type.id}", default: nil)
  end

  def conditionally_prohibitive?
    measure_type.prohibitive? && additional_code.present?
  end

  def prohibitive?
    measure_type.prohibitive? && measure_conditions.none? && additional_code.blank?
  end

  def residual?
    measure_type.prohibitive? && additional_code.residual? && measure_conditions.none?
  end

  def measurement_units?
    measure_components.any?(&:measurement_unit)
  end

  private

  def excluded_country_ids
    @excluded_country_ids ||= excluded_countries.map(&:id)
  end
end
