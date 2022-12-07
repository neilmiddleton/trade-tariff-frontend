require 'spec_helper'

RSpec.describe NewsItemHelper, type: :helper do
  include ServiceHelper
  include ApplicationHelper

  describe '#format_news_item_content' do
    subject(:formatted) { format_news_item_content source }

    let :source do
      <<~EOCONTENT
        # Heading for [[SERVICE_NAME]]

        This is a para <a href="/" target="_blank">test</a>
      EOCONTENT
    end

    it 'converts markdown' do
      expect(formatted).to have_css 'h1'
    end

    it 'replaces service tags' do
      expect(formatted).to have_content 'Heading for UK'
    end
  end

  describe '#markdown_heading_id' do
    subject { markdown_heading_id 'This is a Heading with punctuation!' }

    it { is_expected.to eq 'this-is-a-heading-with-punctuation' }
  end
end
