require 'addressable/uri'

class SearchController < ApplicationController
  before_action :disable_switch_service_banner, only: [:quota_search]
  before_action :disable_search_form, except: [:search]

  def search
    @results = @search.perform

    respond_to do |format|
      format.html do
        if @search.missing_search_term?
          redirect_to missing_search_query_fallback_url
        elsif @results.exact_match?
          redirect_to url_for @results.to_param.merge(url_options).merge(only_path: true)
        elsif @results.none? && @search.search_term_is_commodity_code?
          redirect_to commodity_path(@search.q)
        elsif @results.none? && @search.search_term_is_heading_code?
          redirect_to heading_path(@search.q)
        end
      end

      format.json do
        render json: SearchPresenter.new(@search, @results)
      end

      format.atom
    end
  end

  def suggestions
    search_term = Regexp.escape(params[:term].to_s.strip)
    start_with = SearchSuggestion.start_with(search_term).sort_by(&:value)
    results = start_with.map { |s| { id: s.value, text: s.value } }

    render json: { results: }
  end

  def quota_search
    if TradeTariffFrontend::ServiceChooser.xi?
      raise TradeTariffFrontend::FeatureUnavailable
    end

    form = QuotaSearchForm.new(params.permit(*QuotaSearchForm::PERMITTED_PARAMS))
    @result = QuotaSearchPresenter.new(form)

    respond_to do |format|
      format.html
    end
  end

  def additional_code_search
    form = AdditionalCodeSearchForm.new(params.permit(:code,
                                                      :type,
                                                      :description,
                                                      :page))
    @result = AdditionalCodeSearchPresenter.new(form)
    respond_to do |format|
      format.html
    end
  end

  def footnote_search
    form = FootnoteSearchForm.new(params.permit(:code,
                                                :type,
                                                :description,
                                                :page))
    @result = FootnoteSearchPresenter.new(form)
    respond_to do |format|
      format.html
    end
  end

  def certificate_search
    form = CertificateSearchForm.new(params.permit(:code,
                                                   :type,
                                                   :description,
                                                   :page))
    @result = CertificateSearchPresenter.new(form)

    respond_to do |format|
      format.html
    end
  end

  def chemical_search
    form = ChemicalSearchForm.new(params.permit(:cas, :name, :page))
    @result = ChemicalSearchPresenter.new(form)

    respond_to do |format|
      format.html
    end
  end

  private

  def anchor
    params.dig(:search, :anchor).to_s.gsub(/[^a-zA-Z_\-]/, '').presence
  end

  def missing_search_query_fallback_url
    return sections_url(anchor:) if request.referer.blank?

    back_url = Addressable::URI.parse(request.referer)
    if back_url.host.present? && back_url.host != request.host
      return sections_url(anchor:)
    end

    back_url.query_values ||= {}
    back_url.query_values = back_url.query_values.merge(@search.query_attributes)
    if @search.date.today?
      back_url.query_values = back_url.query_values.except('year', 'month', 'day')
    end
    back_url.fragment = anchor

    back_url.to_s
  end
end
