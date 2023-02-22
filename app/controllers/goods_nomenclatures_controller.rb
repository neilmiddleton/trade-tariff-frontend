class GoodsNomenclaturesController < ApplicationController
  rescue_from Faraday::ResourceNotFound, with: :find_relevant_goods_code_or_fallback

  private

  def goods_code_id
    params.fetch(:id, '')
  end

  def find_relevant_goods_code_or_fallback
    @search = Search.new(
      q: goods_code_id,
      day: @tariff_last_updated.try(:day),
      month: @tariff_last_updated.try(:month),
      year: @tariff_last_updated.try(:year),
    )
    results = @search.perform

    if results.exact_match?
      redirect_to url_for(results.to_param.merge(url_options).merge(only_path: true))
    else
      redirect_to sections_path
    end
  end
end
