require 'spec_helper'

RSpec.describe RulesOfOrigin::Steps::Base do
  subject(:instance) { mock_step.new wizard, wizardstore }

  include_context 'with rules of origin store'

  let :mock_step do
    Class.new(described_class) {}
  end

  let :wizard do
    RulesOfOrigin::Wizard.new wizardstore,
                              RulesOfOrigin::Wizard.steps.first.key
  end

  it { is_expected.to have_attributes service: 'uk' }
  it { is_expected.to have_attributes service_country_name: 'the UK' }
  it { is_expected.to have_attributes trade_country_name: country.description }
  it { is_expected.to have_attributes commodity_code: wizardstore['commodity_code'] }
  it { is_expected.to have_attributes chosen_scheme: schemes.first }
  it { is_expected.to have_attributes origin_reference_document: schemes.first.origin_reference_document }

  describe '#scheme_title' do
    subject { instance.scheme_title }

    it { is_expected.to eql schemes.first.title }

    context 'with multiple schemes' do
      include_context 'with rules of origin store', :importing, scheme_count: 2,
                                                                chosen_scheme: 2

      it { is_expected.to eql schemes.second.title }
    end
  end

  describe '#origin_reference_document' do
    subject { instance.origin_reference_document }

    it { is_expected.to eql schemes.first.origin_reference_document }

    context 'with multiple schemes' do
      include_context 'with rules of origin store', :importing, scheme_count: 2,
                                                                chosen_scheme: 2

      it { is_expected.to eql schemes.second.origin_reference_document }
    end
  end

  describe '#exporting?' do
    subject { instance.exporting? }

    context 'with unilateral scheme so import_only' do
      let(:schemes) { build_list :rules_of_origin_scheme, 1, unilateral: true }

      it { is_expected.to be false }
    end

    context 'when importing' do
      include_context 'with rules of origin store', :importing

      it { is_expected.to be false }
    end

    context 'when exporting' do
      include_context 'with rules of origin store', :exporting

      it { is_expected.to be true }
    end
  end
end
