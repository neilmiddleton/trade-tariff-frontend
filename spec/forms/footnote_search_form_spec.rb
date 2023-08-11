RSpec.describe FootnoteSearchForm, type: :model, vcr: { cassette_name: 'search#footnote_search', record: :new_episodes } do
  describe '.footnote_types' do
    subject(:footnote_types) { described_class.footnote_types }

    it { is_expected.to eq(%w[01 02 03 04 AD CA CD CG CO CR DS DU EU EX IS MG MH MX NC NM NX OZ PB PE PH PI PN PR SN TM TN TP TR WR]) }
  end

  describe 'validations' do
    subject(:form) { described_class.new(params) }

    before { form.valid? }

    context 'when the code is valid' do
      let(:params) { { code: 'CD180' } }

      it { is_expected.to be_valid }
      it { expect(form.errors).to be_empty }
    end

    context 'when the description is valid' do
      let(:params) { { description: 'plastic' } }

      it { is_expected.to be_valid }
      it { expect(form.errors).to be_empty }
    end

    context 'when neither code nor description are present' do
      let(:params) { { code: '', description: '' } }

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:description]).to eq(['You need to supply at least a description']) }
      it { expect(form.errors[:code]).to eq(['You need to supply at least a 5-digit footnote code']) }
    end

    context 'when the code is too short ' do
      let(:params) { { code: '823' } }

      let(:expected_error) do
        ['The footnote code must have 5 digits', 'You have specified a footnote type that does not exist']
      end

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:code]).to eq(expected_error) }
    end

    context 'when the code is a type that does not exist' do
      let(:params) { { code: '11234' } }

      let(:expected_error) do
        ['You have specified a footnote type that does not exist']
      end

      it { is_expected.not_to be_valid }
      it { expect(form.errors[:code]).to eq(expected_error) }
    end
  end

  describe '#type' do
    subject(:type) { described_class.new(params).type }

    context 'when the code is valid' do
      let(:params) { { code: 'CD180' } }

      it { is_expected.to eq('CD') }
    end

    context 'when the code is not set' do
      let(:params) { {} }

      it { is_expected.to eq('') }
    end
  end

  describe '#to_params' do
    subject(:params) { described_class.new(code: 'CD180', description: 'plastic').to_params }

    it { is_expected.to eq(code: '180', type: 'CD', description: 'plastic') }
  end
end
