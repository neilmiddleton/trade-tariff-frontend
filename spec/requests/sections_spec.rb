require 'spec_helper'

RSpec.describe 'SectionsController', type: :request do
  describe 'GET #index' do
    subject(:response) { get sections_path }

    context 'with UK service' do
      include_context 'with UK service'

      it { expect(response).to redirect_to '/find_commodity' }
    end

    context 'with XI service' do
      include_context 'with XI service'

      it { expect(response).to redirect_to '/xi/find_commodity' }
    end
  end

  describe 'GET #show' do
    context 'when requested as HTML' do
      before do
        VCR.use_cassette('geographical_areas#countries') do
          VCR.use_cassette('sections#show') do
            visit section_path(1)
          end
        end
      end

      it 'displays section name' do
        expect(page).to have_content 'Live animals; animal products'
      end

      it 'displays the first chapter in the section' do
        expect(page).to have_content 'Live animals'
      end

      it 'displays the second chapter in the section' do
        expect(page).to have_content 'Meat and edible meat offal'
      end
    end
  end
end
