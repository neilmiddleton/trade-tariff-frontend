require 'spec_helper'

RSpec.describe PagesController, type: :controller do
  context 'when asked for XML file' do
    render_views

    before do
      get :opensearch, format: 'xml'
    end

    it { is_expected.to respond_with(:success) }

    it 'renders OpenSearch file successfully' do
      expect(response.body).to include 'Tariff'
    end
  end

  describe 'GET #privacy' do
    subject(:response) { get :privacy }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('pages/privacy') }
  end

  describe 'GET #help' do
    subject(:response) { get :help }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('pages/help') }
  end

  describe 'GET #cn2021_cn2022', vcr: { cassette_name: 'chapters' } do
    subject(:response) { get :cn2021_cn2022 }

    it { is_expected.to have_http_status(:ok) }
    it { is_expected.to render_template('pages/cn2021_cn2022') }

    it 'assigns chapters' do
      response
      expect(assigns[:chapters]).not_to be_nil
    end
  end
end
