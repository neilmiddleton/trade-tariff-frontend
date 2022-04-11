require 'spec_helper'

RSpec.describe 'search/certificate_search', type: :view, vcr: { cassette_name: 'search#certificate_search_form' } do
  subject { render }

  before { assign :result, result }

  let(:result) do
    instance_double(
      'CertificateSearchPresenter',
      search_form:,
      search_result: certificates,
      with_errors:,
    )
  end

  let(:search_form) { build(:certificate_search_form) }

  context 'when there are results and no errors' do
    let(:certificates) { build(:kaminari, collection: build_list(:certificate, 2)) }
    let(:with_errors) { false }

    it { is_expected.to have_css('article.search-results h1.govuk-heading-l', text: 'Certificate search results') }
  end

  context 'when there are no results and the search includes errors' do
    let(:certificates) { [] }
    let(:with_errors) { true }

    it { is_expected.to have_css('article.search-results h1.govuk-heading-l', text: /Sorry, there is a problem with the search query./) }
  end

  context 'when there are no results and no errors' do
    let(:certificates) { [] }
    let(:with_errors) { false }

    it { is_expected.to have_css('article.search-results h1.govuk-heading-l', text: 'There are no matching results') }
  end
end
