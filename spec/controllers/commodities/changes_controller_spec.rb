require 'spec_helper'

RSpec.describe Commodities::ChangesController, 'GET to #index', type: :controller do
  describe 'commodity is valid at given date', vcr: { cassette_name: 'commodities_changes#index' } do
    let!(:commodity) { Commodity.new(attributes_for(:commodity, goods_nomenclature_item_id: '0101210000')) }

    before do
      get :index, params: { commodity_id: commodity.short_code }, format: :atom
    end

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:changeable)).to be_present }
    it { expect(assigns(:changes)).to be_a(ChangesPresenter) }
  end

  describe 'commodity has no changes at given date', vcr: { cassette_name: 'commodities_changes#index_0702000007_2020-07-22', record: :new_episodes }, type: :controller do
    let!(:commodity) { Commodity.new(attributes_for(:commodity, goods_nomenclature_item_id: '0702000007')) }

    before do
      get :index, params: { commodity_id: commodity.short_code, year: '2020', month: '07', day: '22'}, format: :atom
    end

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:changeable)).to be_present }
    it { expect(assigns(:changes)).to be_a(ChangesPresenter) }

    it 'fetches no changes' do
      expect(assigns[:changes]).to be_empty
    end
  end

  describe 'commodity is not valid at given date', vcr: { cassette_name: 'commodities_changes#index_4302130000_2013-11-11' } do
    let!(:commodity) { Commodity.new(attributes_for(:commodity, goods_nomenclature_item_id: '4302130000')) }

    let :request_page do
      get :index, params: { commodity_id: commodity.short_code, as_of: Date.new(2013, 11, 11) }, format: :atom
    end

    it { expect { request_page }.to raise_exception Faraday::ResourceNotFound }
  end
end
