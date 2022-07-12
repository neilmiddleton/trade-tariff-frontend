require 'spec_helper'

RSpec.describe MeasuresHelper, type: :helper do
  describe '#filter_duty_expression' do
    subject(:filtered_expression) { helper.filter_duty_expression(measure) }

    let(:measure) { Measure.new(attributes_for(:measure, duty_expression:)) }

    context 'when the duty expression is present' do
      let(:duty_expression) { attributes_for(:duty_expression) }

      it { expect(filtered_expression).to match('80.50 EUR / <abbr title="Hectokilogram">Hectokilogram</abbr>') }
    end

    context 'when the duty expression is `NIHIL`' do
      let(:duty_expression) { attributes_for(:duty_expression, formatted_base: 'NIHIL') }

      it { expect(filtered_expression).to eq('') }
    end

    context 'when geographical area and measure type have a not applicable duty rate' do
      let(:measure) do
        Measure.new(attributes_for(:measure, duty_expression:,
                                             geographical_area_id: '1080',
                                             measure_type_id: '103'))
      end

      let(:duty_expression) { attributes_for(:duty_expression) }

      it { expect(filtered_expression).to eq('n/a') }
    end
  end

  describe '#legal_act_regulation_url_link_for' do
    let(:measure) { build(:measure, legal_acts:) }

    context 'when there are no legal acts' do
      let(:legal_acts) { [] }

      it { expect(helper.legal_act_regulation_url_link_for(measure)).to eq('') }
    end

    context 'when the legal act has no regulation url' do
      let(:legal_acts) { [attributes_for(:legal_act, regulation_url: '')] }

      it { expect(helper.legal_act_regulation_url_link_for(measure)).to eq('') }
    end

    context 'when the legal act has a regulation url' do
      let(:legal_acts) { [attributes_for(:legal_act)] }
      let(:expected_link) do
        '<a target="_blank" rel="noopener noreferrer" class="govuk-link" title="The Customs Tariff (Preferential Trade Arrangements) (EU Exit) (Amendment) Regulations 2021" href="https://www.legislation.gov.uk/uksi/2020/1432">S.I. 2020/1432</a>'
      end

      it { expect(helper.legal_act_regulation_url_link_for(measure)).to eq(expected_link) }
      it { expect(helper.legal_act_regulation_url_link_for(measure)).to be_html_safe }
    end
  end

  describe 'check_how_to_export_goods_link' do
    subject(:link) do
      check_how_to_export_goods_link(declarable:, country_code: '', country_name: '', eu_member:)
    end

    let(:declarable) { build(:commodity, goods_nomenclature_item_id: '1234567890') }

    context 'when it is a EU member' do
      let(:eu_member) { true }

      it 'pass in the code as argument' do
        expect(link).to include('pc=1234567890')
      end
    end

    context 'when it is NOT a EU member' do
      let(:eu_member) { false }

      it 'does not include params' do
        expect(link).not_to include('pc=')
      end
    end
  end

  describe '#control_line_wrapping_in_duty_expression' do
    subject { control_line_wrapping_in_duty_expression expression }

    context 'with simple percentage' do
      let(:expression) { '<span>20.00</span> % ' }

      it { is_expected.to have_css 'span.duty-expression > span', text: '20.00 %' }
    end

    context 'with abbreviation' do
      let :expression do
        '<span>16.50</span> % / <abbr title="Retail Price">Retail Price</abbr> '
      end

      it { is_expected.to have_css 'span.duty-expression > span > abbr', text: 'Retail Price' }
    end

    context 'with strong tag' do
      let :expression do
        '<strong><span>16.50</span> % / <abbr title="Retail Price">Retail Price</abbr> </strong>'
      end

      it { is_expected.to have_css 'strong.duty-expression > span > abbr', text: 'Retail Price' }
    end

    context 'with multi segment expression' do
      let :expression do
        '<span>16.50</span> % / <abbr title="Retail Price">Retail Price</abbr> ' \
        '+ <span>244.78</span> GBP / <abbr title="1000 items">1000 p/st</abbr> ' \
        'MIN <span>320.90</span> GBP / <abbr title="1000 items">1000 p/st</abbr>'
      end

      let :expected do
        '<span class="duty-expression">' \
        '<span>16.50 % / <abbr title="Retail Price">Retail Price</abbr></span> ' \
        '+ <span>244.78 GBP / <abbr title="1000 items">1000 p/st</abbr></span> ' \
        'MIN <span>320.90 GBP / <abbr title="1000 items">1000 p/st</abbr></span>' \
        '</span>'
      end

      it { is_expected.to match expected }
    end
  end

  describe '#format_measure_condition_requirement' do
    subject { format_measure_condition_requirement condition }

    context 'with threshold condition' do
      context 'with weight condition' do
        let(:condition) { build :measure_condition, :weight }

        it { is_expected.to match 'The weight of your goods does not exceed' }
      end

      context 'with volume condition' do
        let(:condition) { build :measure_condition, :volume }

        it { is_expected.to match 'The volume of your goods does not exceed' }
      end

      context 'with price condition' do
        let(:condition) { build :measure_condition, :price }

        it { is_expected.to match 'The price of your goods does not exceed' }
      end

      context 'with eps condition' do
        let(:condition) { build :measure_condition, :eps }

        it { is_expected.to match 'The price of your goods does not exceed' }
      end

      context 'with other threshold' do
        let(:condition) { build :measure_condition, :threshold }

        it { is_expected.to be_present }
        it { is_expected.not_to match 'of your goods' }
      end
    end

    context 'with any other classification of condition' do
      context 'with certificate description' do
        let :condition do
          build :measure_condition, certificate_description: 'test description',
                                    requirement: 'test requirement'
        end

        it { is_expected.to match 'test description' }
      end

      context 'with requirement but no certificate description' do
        let :condition do
          build :measure_condition, certificate_description: nil,
                                    requirement: 'test requirement'
        end

        it { is_expected.to match 'test requirement' }
      end

      context 'with neither' do
        let :condition do
          build :measure_condition, certificate_description: nil,
                                    requirement: nil
        end

        it { is_expected.to match 'No document provided' }
      end
    end
  end

  describe '#format_measure_condition_document_code' do
    subject { format_measure_condition_document_code condition }

    context 'with threshold condition' do
      let(:condition) { build :measure_condition, :threshold }

      it { is_expected.to eql 'Threshold condition' }
    end

    context 'with any other classification of condition' do
      let(:condition) { build :measure_condition, document_code: 'X123' }

      it { is_expected.to eql 'X123' }
    end
  end

  describe '#format_combined_conditions_requirement' do
    subject { format_combined_conditions_requirement conditions }

    context 'with one threshold condition' do
      let(:conditions) { build_list :measure_condition, 1, :threshold }

      it { is_expected.to be_nil }
    end

    context 'with one document condition' do
      let(:conditions) { build_list :measure_condition, 1 }

      it { is_expected.to be_nil }
    end

    context 'with two threshold conditions' do
      let(:conditions) { build_pair :measure_condition, :threshold }

      it { is_expected.to eql 'Meet both conditions' }
    end

    context 'with two document conditions' do
      let(:conditions) { build_pair :measure_condition }

      it { is_expected.to eql 'Provide both documents' }
    end

    context 'with three threshold conditions' do
      let(:conditions) { build_list :measure_condition, 3, :threshold }

      it { is_expected.to eql 'Meet all conditions' }
    end

    context 'with three document conditions' do
      let(:conditions) { build_list :measure_condition, 3 }

      it { is_expected.to eql 'Provide all documents' }
    end
  end
end
