require 'spec_helper'

describe EtdVocabulary do
  let(:field_type) { 'some_field' }
  let(:vocab) { FactoryGirl.build(:etd_vocabulary) }
  subject { vocab }


  describe 'class methods' do
    subject { EtdVocabulary }
    its(:inspect) { should match /\AEtdVocabulary/ }

      it 'returns field values for given field type' do
        test = FactoryGirl.create(:etd_vocabulary, field_type: "etd_field_type", field_value:"bogus value")
        test1 = FactoryGirl.create(:etd_vocabulary, field_type: "etd_field_type", field_value:"bogus value1")
        test2 = FactoryGirl.create(:etd_vocabulary, field_type: "etd_field_type", field_value:"bogus value2")
        result = EtdVocabulary.values_for("etd_field_type")

        expect(result).to eq ["bogus value","bogus value1","bogus value2"]

      end


  end

end
