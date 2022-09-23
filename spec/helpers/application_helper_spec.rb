require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#home_path' do
    subject(:home_path) { helper.home_path }

    it { is_expected.to eq(find_commodity_path) }
  end

  describe '#home_url' do
    subject(:home_url) { helper.home_url }

    it { is_expected.to eq(find_commodity_url) }
  end

  describe '#govspeak' do
    context 'with string without HTML code' do
      let(:string) { '**hello**' }

      it 'renders string in Markdown as HTML' do
        expect(
          helper.govspeak(string).strip,
        ).to eq '<p><strong>hello</strong></p>'
      end
    end

    context 'when string contains Javascript code' do
      let(:string) { "<script type='text/javascript'>alert('hello');</script>" }

      it '<script> tags with a content are filtered' do
        expect(
          helper.govspeak(string).strip,
        ).to eq ''
      end
    end

    context 'when HashWithIndifferentAccess is passed as argument' do
      let(:hash) do
        { 'content' => '* 1\\. This chapter does not cover:' }
      end

      it 'fetches :content from the hash' do
        expect(
          helper.govspeak(hash),
        ).to eq <<~FOO
          <ul>
            <li>1. This chapter does not cover:</li>
          </ul>
        FOO
      end
    end

    context 'when HashWithIndifferentAccess is passed as argument with no applicable content' do
      let(:na_hash) do
        { 'foo' => 'bar' }
      end

      it 'returns an empty string' do
        expect(
          helper.govspeak(na_hash),
        ).to eq ''
      end
    end

    context 'with link with target attribute' do
      subject { govspeak source }

      let(:source) { %(<a href="/" target="_blank">/</a>) }

      it { is_expected.to eql "<p>#{source}</p>\n" }
    end
  end

  describe '.generate_breadcrumbs' do
    context 'with single page' do
      subject { generate_breadcrumbs 'Current Page', [] }

      it { is_expected.to have_css 'nav.govuk-breadcrumbs[aria-label="Breadcrumb"]' }
      it { is_expected.to have_css 'nav ol.govuk-breadcrumbs__list' }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item', count: 1 }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item a.govuk-breadcrumbs__link', count: 0 }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item', text: 'Current Page' }
    end

    context 'with nested pages' do
      subject { generate_breadcrumbs 'Current Page', [['Previous Page', '/']] }

      it { is_expected.to have_css 'nav.govuk-breadcrumbs[aria-label="Breadcrumb"]' }
      it { is_expected.to have_css 'nav ol.govuk-breadcrumbs__list' }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item', count: 2 }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item a.govuk-breadcrumbs__link', count: 1 }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item', text: 'Current Page' }
      it { is_expected.to have_link 'Previous Page', href: '/' }
    end
  end

  describe '#breadcrumb_link_or_text' do
    context 'when the breadcrumb item is the last one' do
      it 'returns plain text' do
        breadcrumb_item = breadcrumb_link_or_text('AAA', nil, 'Link description')

        expect(breadcrumb_item).to eq('Link description')
      end
    end

    context 'when the breadcrumb item is NOT the last one' do
      it 'returns a link (which allows to go back)' do
        breadcrumb_item = breadcrumb_link_or_text('AAA', 'BBB', 'Link description')

        expect(breadcrumb_item).to eq('<a class="govuk-breadcrumbs__link" href="AAA">Link description</a>')
      end
    end
  end

  describe '#search_active_class' do
    subject { helper.search_active_class }

    before do
      allow(helper).to receive(:controller_name).and_return controller_name
      allow(helper).to receive(:action_name).and_return action
    end

    context 'with sections page' do
      let(:controller_name) { 'sections' }
      let(:action) { 'index' }

      it { is_expected.to eq 'active' }
    end

    context 'with find_commodity page' do
      let(:controller_name) { 'find_commodities' }
      let(:action) { 'show' }

      it { is_expected.to eq 'active' }
    end

    context 'with search results page' do
      let(:controller_name) { 'search' }
      let(:action) { 'search' }

      it { is_expected.to eq 'active' }
    end

    context 'with another page' do
      let(:controller_name) { 'browse' }
      let(:action) { 'index' }

      it { is_expected.to be_nil }
    end
  end

  describe '#a_z_active_class' do
    subject { helper.a_z_active_class }

    context 'when controller is search_references' do
      before { allow(helper).to receive(:controller_name).and_return('search_references') }

      it { is_expected.to eql 'active' }
    end

    context 'when controller is not tools' do
      before { allow(helper).to receive(:controller_name).and_return('something') }

      it { is_expected.to be_nil }
    end
  end

  describe '#tools_active_class' do
    subject { helper.tools_active_class }

    context 'when action is tools' do
      before { allow(helper).to receive(:action_name).and_return('tools') }

      it { is_expected.to eql 'active' }
    end

    context 'when action is not tools' do
      before { allow(helper).to receive(:action_name).and_return('something') }

      it { is_expected.to be_nil }
    end
  end

  describe '#help_active_class' do
    subject { helper.help_active_class }

    context 'when action is tools' do
      before { allow(helper).to receive(:action_name).and_return('help') }

      it { is_expected.to eql 'active' }
    end

    context 'when action is not tools' do
      before { allow(helper).to receive(:action_name).and_return('something') }

      it { is_expected.to be_nil }
    end
  end

  describe '#browse_active_class' do
    subject { helper.browse_active_class }

    context 'with browse controller' do
      before { allow(helper).to receive(:controller_name).and_return 'browse_sections' }

      it { is_expected.to eql 'active' }
    end

    context 'with other controller' do
      before { allow(helper).to receive(:controller_name).and_return 'search' }

      it { is_expected.to be_nil }
    end
  end

  describe '#updates_active_class' do
    subject { helper.updates_active_class }

    context 'with news_items controller' do
      before { allow(helper).to receive(:controller_name).and_return 'news_items' }

      it { is_expected.to eql 'active' }
    end

    context 'with other controller' do
      before { allow(helper).to receive(:controller_name).and_return 'search' }

      it { is_expected.to be_nil }
    end
  end

  describe '#page_header' do
    before do
      allow(helper).to receive(:is_switch_service_banner_enabled?)
                         .and_return switch_banner
    end

    let(:switch_banner) { true }

    context 'without block' do
      subject { helper.page_header 'Test header' }

      it { is_expected.to have_css 'header span.govuk-caption-xl', text: I18n.t('title.service_name.uk') }
      it { is_expected.to have_css 'header h1.govuk-heading-l', text: 'Test header' }
      it { is_expected.to have_css 'header > *', count: 2 }
      it { is_expected.to have_css 'header span.switch-service-control' }
    end

    context 'with block' do
      subject { helper.page_header('Second header') { tag.em 'additional content' } }

      it { is_expected.to have_css 'header span.govuk-caption-xl', text: I18n.t('title.service_name.uk') }
      it { is_expected.to have_css 'header h1.govuk-heading-l', text: 'Second header' }
      it { is_expected.to have_css 'header > *', count: 3 }
      it { is_expected.to have_css 'header span.switch-service-control' }
      it { is_expected.to have_css 'header em', text: 'additional content' }
    end

    context 'with XI service' do
      subject { helper.page_header 'Test header' }

      include_context 'with XI service'

      it { is_expected.to have_css 'header span.govuk-caption-xl', text: I18n.t('title.service_name.xi') }
    end

    context 'with switch banner disabled' do
      let(:switch_banner) { false }

      it { is_expected.not_to have_css 'span.switch-service-control' }
    end
  end

  describe '#css_heading_size' do
    subject { helper.css_heading_size(text) }

    context 'when text length is greater than or equal to 400 chars' do
      let(:text) { 'X' * 400 }

      it { is_expected.to eq 'govuk-heading-s' } # Small text
    end

    context 'when text length is between 120 and 400 chars' do
      let(:text) { 'X' * 150 }

      it { is_expected.to eq 'govuk-heading-m' } # Medium text
    end

    context 'when text length is smaller than 120 chars' do
      let(:text) { 'X' * 119 }

      it { is_expected.to eq 'govuk-heading-l' } # Large text
    end
  end

  describe '#present_from_to' do
    shared_examples_for 'a from to expression' do |expected_expression, start_date, end_date|
      subject(:from_to) { helper.present_from_to(from, to) }

      let(:from) { start_date && Date.parse(start_date) }
      let(:to) { end_date && Date.parse(end_date) }

      it { is_expected.to eq(expected_expression) }
    end

    it_behaves_like 'a from to expression', ' From 1 Jan 2022 to 1 Feb 2023', '2022-01-01', '2023-02-01'
    it_behaves_like 'a from to expression', ' From 1 Jan 2022', '2022-01-01', nil
    it_behaves_like 'a from to expression', nil, nil, '2023-02-01'
    it_behaves_like 'a from to expression', nil, nil, nil
  end

  describe '#govuk_date_range' do
    let(:from) { Date.parse('2022-01-01') }
    let(:to) { Date.parse('2022-06-01') }

    context 'with TimeWithZone' do
      subject { govuk_date_range from.in_time_zone, to.in_time_zone }

      it { is_expected.to eql '1 January 2022 to 1 June 2022' }
    end

    context 'with String Dates' do
      subject { govuk_date_range from.to_s, to.to_s }

      it { is_expected.to eql '1 January 2022 to 1 June 2022' }
    end

    context 'with String Dates with Times' do
      subject { govuk_date_range "#{from} 01:01:00", "#{to} 01:02:00" }

      it { is_expected.to eql '1 January 2022 to 1 June 2022' }
    end

    context 'with XML Time Strings' do
      subject { govuk_date_range from.xmlschema, to.xmlschema }

      it { is_expected.to eql '1 January 2022 to 1 June 2022' }
    end

    context 'with Dates' do
      subject { govuk_date_range from, to }

      it { is_expected.to eql '1 January 2022 to 1 June 2022' }
    end
  end

  describe '#paragraph_if_content' do
    subject { paragraph_if_content content }

    context 'with content' do
      let(:content) { 'this is some <em>content</em>'.html_safe }

      it { is_expected.to have_css 'p', text: /this is some/ }
      it { is_expected.to have_css 'p em', text: 'content' }
    end

    context 'with nil' do
      let(:content) { nil }

      it { is_expected.to be_nil }
    end

    context 'with blank string' do
      let(:content) { '' }

      it { is_expected.to be_nil }
    end
  end
end
