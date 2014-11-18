require 'spec_helper'

describe Affiliation do

  let(:affiliation) { 'staff'  }

  subject { described_class.new(affiliation) }

  it { should respond_to :key }

  it { should respond_to :human_name }

  it { should respond_to :label }

  describe 'with affiliation_type: other' do
    let(:affiliation) { "other" }
    it 'return name for given key' do
      subject.to_s.should == 'Other'
    end

    it 'return description for given key' do
      subject.label.should == 'Other'
    end
  end

  describe 'with affiliation_type: nil' do
    let(:affiliation) { double('Value') }
    it 'raises an error as invalid value' do
      expect{
        subject
      }.to raise_error(RuntimeError)
    end
  end

end
