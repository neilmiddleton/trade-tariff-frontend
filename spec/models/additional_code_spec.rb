require 'spec_helper'

RSpec.describe AdditionalCode do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[measures]) }
  end

  it_behaves_like 'an entity that has goods nomenclatures' do
    let(:entity) { build(:additional_code, measures:) }
  end
end
