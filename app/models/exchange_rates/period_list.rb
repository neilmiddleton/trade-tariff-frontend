require 'api_entity'

class ExchangeRates::PeriodList
  include ApiEntity

  attr_accessor :year, :type

  has_many :exchange_rate_years, class_name: 'ExchangeRates::Year'
  has_many :exchange_rate_periods, class_name: 'ExchangeRates::Period'

  def publication_date
    raise Faraday::ResourceNotFound if exchange_rate_periods.empty?

    date_str = exchange_rate_periods.first.files.first&.publication_date
    date = Date.parse(date_str) if date_str
    date&.to_formatted_s(:long)
  end

  def type_label
    return 'monthly' if type == 'scheduled'

    type
  end
end
