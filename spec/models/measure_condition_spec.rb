require 'spec_helper'

RSpec.describe MeasureCondition do
  subject(:condition) { build(:measure_condition) }

  it { is_expected.to respond_to :condition_code }
  it { is_expected.to respond_to :condition }
  it { is_expected.to respond_to :document_code }
  it { is_expected.to respond_to :action }
  it { is_expected.to respond_to :duty_expression }
  it { is_expected.to respond_to :certificate_description }
  it { is_expected.to respond_to :measure_condition_class }

  describe '#requirement' do
    it { expect(condition.requirement).to be_html_safe }
  end

  it_behaves_like 'a resource that has attributes',
                  condition_code: 'B',
                  condition: 'B: Presentation of a certificate/licence/document',
                  document_code: 'A000',
                  action: 'The entry into free circulation is not allowed',
                  duty_expression: '',
                  certificate_description: 'Foo bar',
                  guidance_cds: 'CDS guiance',
                  guidance_chief: 'CHIEF guiance',
                  requirement: 'requirement'

  describe '#has_guidance?' do
    context 'when the condition has guidance' do
      subject(:condition) { build(:measure_condition, :with_guidance) }

      it { is_expected.to have_guidance }
    end

    context 'when the condition does not have guidance' do
      subject(:condition) { build(:measure_condition) }

      it { is_expected.not_to have_guidance }
    end
  end

  describe '#measure_condition_class' do
    subject { condition.measure_condition_class }

    let :condition do
      build :measure_condition, measure_condition_class: condition_class
    end

    context 'with nil class' do
      let(:condition_class) { nil }

      it { is_expected.to eql '' }
      it { is_expected.to respond_to :threshold? }
      it { is_expected.to respond_to :document? }
      it { is_expected.to have_attributes 'threshold?': false }
      it { is_expected.to have_attributes 'document?': false }
    end

    context 'with document_class' do
      let(:condition_class) { 'document' }

      it { is_expected.to eql 'document' }
      it { is_expected.to respond_to :threshold? }
      it { is_expected.to respond_to :document? }
      it { is_expected.to have_attributes 'threshold?': false }
      it { is_expected.to have_attributes 'document?': true }
    end
  end
end
