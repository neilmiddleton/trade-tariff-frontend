module MeursingLookup
  class StepsController < ApplicationController
    before_action do
      disable_search_form
      disable_last_updated_footnote
      disable_switch_service_banner

      clear_meursing_lookup_session
      store_meursing_lookup_result_on_session
      set_goods_nomenclature_code
    end

    include GoodsNomenclatureHelper
    include WizardSteps

    self.wizard_class = MeursingLookup::Wizard

    private

    def wizard_store_key
      :meursing_lookup
    end

    def step_path(step_id = params[:id])
      meursing_lookup_step_path(step_id, goods_nomenclature_code: current_goods_nomenclature_code)
    end

    def store_meursing_lookup_result_on_session
      session[Result::CURRENT_MEURSING_ADDITIONAL_CODE_KEY] = current_step.meursing_code if current_step.key == MeursingLookup::Steps::End.key
    end

    def clear_meursing_lookup_session
      session.delete(wizard_store_key) if current_step.key == MeursingLookup::Steps::Start.key
    end

    def set_goods_nomenclature_code
      @goods_nomenclature_code = params[:goods_nomenclature_code].presence ||
        params.fetch(step_param_key, {})[:goods_nomenclature_code]
    end

    def step_param_key
      "#{wizard_store_key}_steps_#{current_step.key}"
    end
  end
end
