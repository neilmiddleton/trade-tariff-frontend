require 'spec_helper'

RSpec.describe DeclarableHelper, type: :helper do
  describe '#declarable_stw_link' do
    subject(:declarable_stw_link) { helper.declarable_stw_link(declarable, search) }

    let(:declarable) { build(:commodity) }
    let(:geographical_area) { build(:geographical_area, id: 'FR', description: 'France') }
    let(:search) { Search.new(country: 'FR', day: '01', month: '01', year: '2021') }

    before do
      allow(GeographicalArea).to receive(:find).and_return(geographical_area)
    end

    context 'when no date is passed' do
      let(:search) { Search.new(country: 'FR') }

      it { is_expected.to include("importDateDay=#{Time.zone.today.day}") }
      it { is_expected.to include("importDateMonth=#{Time.zone.today.month}") }
      it { is_expected.to include("importDateYear=#{Time.zone.today.year}") }
    end

    context 'when the declarable is a heading' do
      let(:declarable) { build(:heading) }

      it 'returns the expected text' do
        expected_text = "Check how to import heading #{declarable.code} from France."

        expect(declarable_stw_link).to include(expected_text)
      end

      it { is_expected.to include('https://test.com/stw-testing?') }
      it { is_expected.to include("commodity=#{declarable.code}") }
      it { is_expected.to include('originCountry=FR') }
      it { is_expected.to include('goodsIntent=bringGoodsToSell') }
      it { is_expected.to include('userTypeTrader=true') }
      it { is_expected.to include('tradeType=import') }
      it { is_expected.to include('destinationCountry=GB') }
      it { is_expected.to include('importDeclarations=yes') }
      it { is_expected.to include('importOrigin=&') }
      it { is_expected.to include('importDateDay=01') }
      it { is_expected.to include('importDateMonth=01') }
      it { is_expected.to include('importDateYear=2021') }
      it { is_expected.to include('target="_blank"') }
      it { is_expected.to include('rel="noopener"') }
      it { is_expected.to include('class="govuk-link"') }
    end

    context 'when the declarable is a commodity' do
      let(:declarable) { build(:commodity) }

      it 'returns the expected text' do
        expected_text = "Check how to import commodity #{declarable.code} from France."

        expect(declarable_stw_link).to include(expected_text)
      end

      it { is_expected.to include('https://test.com/stw-testing?') }
      it { is_expected.to include("commodity=#{declarable.code}") }
      it { is_expected.to include('originCountry=FR') }
      it { is_expected.to include('goodsIntent=bringGoodsToSell') }
      it { is_expected.to include('userTypeTrader=true') }
      it { is_expected.to include('tradeType=import') }
      it { is_expected.to include('destinationCountry=GB') }
      it { is_expected.to include('importDeclarations=yes') }
      it { is_expected.to include('importOrigin=&') }
      it { is_expected.to include('importDateDay=01') }
      it { is_expected.to include('importDateMonth=01') }
      it { is_expected.to include('importDateYear=2021') }
      it { is_expected.to include('target="_blank"') }
      it { is_expected.to include('rel="noopener"') }
      it { is_expected.to include('class="govuk-link"') }
    end
  end

  describe '#classification_description' do
    let(:declarable) do
      build(:commodity, description: 'Cherry tomatos',
                        ancestors: [
                          attributes_for(:commodity, description: 'Foo1'),
                          attributes_for(:commodity, description: 'Foo2'),
                        ],
                        heading: attributes_for(:heading, description: 'Fruits'))
    end

    it 'returns the correct description' do
      expect(helper.classification_description(declarable))
        .to eq('Fruits &mdash; Foo1 &mdash; Foo2 &mdash; <strong>Cherry tomatos</strong>')
    end
  end

  describe '#supplementary_geographical_area_id' do
    subject(:supplementary_geographical_area_id) { helper.supplementary_geographical_area_id(search) }

    context 'when the country is present on the search' do
      let(:search) { Search.new(country: 'IT') }

      it { is_expected.to eq('IT') }
    end

    context 'when the country is not present on the search' do
      let(:search) { Search.new(country: nil) }

      it { is_expected.to eq('1011') }
    end
  end

  describe '#trading_partner_country_description', vcr: { cassette_name: 'geographical_areas#it' } do
    context 'when the country is a valid country' do
      subject(:trading_partner_country_description) { helper.trading_partner_country_description('IT') }

      it { is_expected.to eq('Italy') }
    end

    context 'when the country is nil' do
      subject(:trading_partner_country_description) { helper.trading_partner_country_description(nil) }

      it { is_expected.to eq('All countries') }
    end
  end
end
