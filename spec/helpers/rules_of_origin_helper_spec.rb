require 'spec_helper'

RSpec.describe RulesOfOriginHelper, type: :helper do
  describe '#rules_of_origin_service_name' do
    subject { helper.rules_of_origin_service_name }

    context 'with uk service' do
      include_context 'with UK service'

      it { is_expected.to eql 'UK' }
    end

    context 'with xi service' do
      include_context 'with XI service'

      it { is_expected.to eql 'EU' }
    end
  end

  describe '#rules_of_origin_schemes_intro' do
    subject { helper.rules_of_origin_schemes_intro(country_name, schemes) }

    let(:country_name) { 'France' }

    context 'with no scheme' do
      let(:schemes) { [] }

      it { is_expected.to have_css '#rules-of-origin__intro--no-scheme' }
      it { is_expected.not_to have_css '#rules-of-origin__intro--bloc-scheme' }
      it { is_expected.not_to have_css '#rules-of-origin__intro--country-scheme' }
    end

    context 'with bloc scheme' do
      let(:schemes) { build_list :rules_of_origin_scheme, 1, countries: %w[FR ES] }

      it { is_expected.not_to have_css '#rules-of-origin__intro--no-scheme' }
      it { is_expected.to have_css '#rules-of-origin__intro--bloc-scheme' }
      it { is_expected.not_to have_css '#rules-of-origin__intro--country-scheme' }
    end

    context 'with country scheme' do
      let(:schemes) { build_list :rules_of_origin_scheme, 1, countries: %w[FR] }

      it { is_expected.not_to have_css '#rules-of-origin__intro--no-scheme' }
      it { is_expected.not_to have_css '#rules-of-origin__intro--bloc-scheme' }
      it { is_expected.to have_css '#rules-of-origin__intro--country-scheme' }
    end
  end

  describe '#rules_of_origin_tagged_descriptions' do
    subject { helper.rules_of_origin_tagged_descriptions(content) }

    context 'without tagged descriptions' do
      let(:content) { 'Some sample content' }

      it { is_expected.to eql content }
    end

    context 'with matching tagged descriptions' do
      let(:content) { "With two tags in\n\n{{CC}}{{CTSH}}" }

      it { is_expected.to start_with 'With two tags in' }
      it { is_expected.to match 'change of chapter' }
      it { is_expected.to match 'change in tariff subheading' }
    end

    context 'with unmatched tagged descriptions' do
      let(:content) { "With two tags in\n\n{{UNKNOWN}}{{CTSH}}" }

      it { is_expected.to start_with 'With two tags in' }
      it { is_expected.not_to match '{{CC}}' }
      it { is_expected.not_to match 'change of chapter' }
      it { is_expected.to match 'change in tariff subheading' }
    end
  end
end
