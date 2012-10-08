class DutyExpressionFormatter
  def self.format(duty_expression_id, duty_expression_description, duty_amount, monetary_unit, measurement_unit, measurement_unit_qualifier)
    @formatted = ""
    if duty_amount.present?
      @formatted << sprintf("%.2f", duty_amount)
    end
    if duty_expression_description.present?
      @formatted << " " << duty_expression_description 
    end
    if monetary_unit.present?
      @formatted << " " << monetary_unit 
    end
    if measurement_unit.present?
      @formatted << "/" << measurement_unit
    end
    if measurement_unit_qualifier.present?
      @formatted << " " << measurement_unit_qualifier
    end
    @formatted
    
    # @formatted = case duty_expression_id
    #              when "01"
    #                if monetary_unit.present? && measurement_unit.present?
    #                  monetary_unit_normalized = case monetary_unit
    #                                             when 'EUC'
    #                                               'EUR (EUC)'
    #                                             else
    #                                               monetary_unit
    #                                             end

    #                  sprintf("%.2f %s/%s", duty_amount, monetary_unit_normalized, measurement_unit)
    #                else
    #                  sprintf("%.2f%", duty_amount)
    #                end
    #              when "02"
    #                sprintf("- %.2f %s/%s", duty_amount,
    #                                        monetary_unit,
    #                                        measurement_unit)
    #              when "03"
    #                sprintf("+ %.2f %s/%s", duty_amount,
    #                                        monetary_unit,
    #                                        measurement_unit)
    #              when "04"
    #                sprintf("+ %.2f %s/%s", duty_amount,
    #                                        monetary_unit,
    #                                        measurement_unit)
    #              when "12"
    #                "+ EA"
    #              when "14"
    #                "+ EA R"
    #              when "15"
    #                if measurement_unit_qualifier.present?
    #                  sprintf("min %.2f %s/(%s/%s)", duty_amount,
    #                                                 monetary_unit,
    #                                                 measurement_unit,
    #                                                 measurement_unit_qualifier)
    #                else
    #                  sprintf("min %.2f %s/%s", duty_amount,
    #                                                 monetary_unit,
    #                                                 measurement_unit)
    #                end
    #              when "17"
    #                sprintf("max %.2f%", duty_amount)
    #              when "19"
    #                sprintf("+ %.2f %s/%s", duty_amount,
    #                                        monetary_unit,
    #                                        measurement_unit)
    #              when "20"
    #                sprintf("+ %.2f %s/%s", duty_amount,
    #                                        monetary_unit,
    #                                        measurement_unit)
    #              when "21"
    #                "+ AD S/Z"
    #              when "25"
    #                "+ AD S/Z R"
    #              when "27"
    #                "+ AD F/M"
    #              when "29"
    #                "+ AD F/M R"
    #              when "35"
    #                sprintf("max %.2f %s/%s", duty_amount,
    #                                          monetary_unit,
    #                                          measurement_unit)
    #              when "36"
    #                sprintf("- %.2f %% CIF", duty_amount)
    #              when "37"
    #                # Empty
    #              when "40"
    #                "Export refunds for cereals"
    #              when "41"
    #                "Export refunds for rice"
    #              when "42"
    #                "Export refunds for eggs"
    #              when "43"
    #                "Export refunds for sugar"
    #              when "44"
    #                "Export refunds for milk products"
    #              when "99"
    #                measurement_unit
    #              end
  end
end
