require 'spec_helper'

RSpec.describe RulesOfOrigin::Link do
  it { is_expected.to respond_to :text }
  it { is_expected.to respond_to :url }

  describe '#id' do
    subject(:link_id) { first_link.id }

    let(:first_link) { build :rules_of_origin_link, id: id }
    let(:second_link) { build :rules_of_origin_link }

    let :third_link do
      build :rules_of_origin_link,
            id: nil,
            text: first_link.text,
            url: first_link.url
    end

    context 'when supplied' do
      let(:id) { 3 }

      it { is_expected.to be 3 }
    end

    context 'when autogenerated' do
      let(:id) { nil }

      it('is generated') { is_expected.to be_present }
      it('is different per instance') { is_expected.not_to eq second_link.id }
      it('is content addressable') { is_expected.to eq third_link.id }
    end
  end
end
