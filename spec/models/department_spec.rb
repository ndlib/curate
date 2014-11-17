require 'spec_helper'

describe Department do

  let(:department_key) { "humanities"  }
  let(:attributes) { DEPARTMENTS.fetch(department_key)  }


  let(:sample_departments) {
      {
        humanities:
        {
          key: "humanities",
          identifier: "Humanities",
          selectable: false},
        asian_languages_and_literature:
        {
          key: "asian_languages_and_literature",
          identifier: "Humanities::Asian Languages And Literature",
          selectable: false},
        chinese_languages_and_literature:
        {
          key: "chinese_languages_and_literature",
          identifier: "Humanities::Asian Languages And Literature::Chinese Languages",
          selectable: true},
        fake_d:
          {
              key: "fake_d",
              identifier: "Asian Languages And Literature::Bogus Department",
              selectable: true}
    }
  }

  before(:each){
    stub_const("DEPARTMENTS", sample_departments.deep_stringify_keys)
  }

  subject { described_class.new(attributes) }


  it { should respond_to :selectable? }

  it { should respond_to :id }

  it { should respond_to :label }

  it { should respond_to :identifier }

  it { should respond_to :to_s }

  describe 'with valid department_key: humanities' do
    let(:department_key) { "asian_languages_and_literature"  }

    it {
      expect {
        Department.new(attributes)
      }.to_not raise_error
    }

    it 'return name for given key' do
      subject.to_s.should == 'Asian Languages And Literature'
    end

    it 'return identifier for given key' do
      subject.identifier.should == 'Humanities::Asian Languages And Literature'
    end

  end

  describe 'with invalid department_key' do
    let(:department_key) { double('Value') }

    it 'raises an error as invalid value' do
      expect{
        subject
      }.to raise_error(KeyError)
    end

  end

  describe 'some of the key features of deportment' do
    let(:department_key) { "chinese_languages_and_literature"  }

    it 'return name for given key' do
      subject.to_s.should == 'Chinese Languages'
    end

    it 'return parents for given key' do
      subject.parents.collect(&:label).should == ["Humanities","Asian Languages And Literature"]
    end

    describe 'children' do
      let(:department_key){"asian_languages_and_literature"}
      it 'get children for given key' do
        subject.children.collect(&:label).should == ["Chinese Languages","Bogus Department"]
      end
    end

  end
end
