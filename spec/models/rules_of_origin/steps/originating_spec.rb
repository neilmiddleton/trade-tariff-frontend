require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::Originating do
  include_context 'with rules of origin store', :importing
  include_context 'with wizard step', RulesOfOrigin::Wizard

  describe '#originating_country' do
    subject { instance.originating_country }

    context 'when importing' do
      it { is_expected.to eql 'Japan' }
    end

    context 'when exporting' do
      include_context 'with rules of origin store', :exporting

      it { is_expected.to eql 'United Kingdom' }
    end
  end

  describe '#scheme_title' do
    subject { instance.scheme_title }

    it { is_expected.to eql schemes.first.title }

    context 'with multiple schemes' do
      include_context 'with rules of origin store', :importing, scheme_count: 2, chosen_scheme: 2

      it { is_expected.to eql schemes.second.title }
    end
  end
end
