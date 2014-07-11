require 'spec_helper'

describe Etd do
  subject { FactoryGirl.build(:etd) }

  it_behaves_like 'with_related_works'
  it_behaves_like 'is_embargoable'
  it_behaves_like 'has_common_solr_fields'

  it { should have_unique_field(:human_readable_type) }
  it { should have_unique_field(:abstract) }
  it { should have_unique_field(:title) }
  it { should have_unique_field(:date_uploaded) }
  it { should have_unique_field(:date_modified) }
  it { should have_unique_field(:identifier) }

  it { should have_multivalue_field(:subject) }
  it { should have_multivalue_field(:publisher) }
  it { should have_multivalue_field(:language) }

  context 'degree duplication error' do
    subject { FactoryGirl.build(:etd) }

    it 'does not keep creating new degree nodes' do
      degree_attributes = [{"level"=>"1", "discipline"=>"Computer Science", "name"=>"Master of Science"}]
      subject.degree_attributes = degree_attributes
      subject.save!
      expect(subject.reload.degree.count).to eq(1)

      degree = subject.degree.first
      degree_attributes.first['id'] = degree.id

      subject.degree_attributes = degree_attributes
      subject.save!
      expect(subject.reload.degree.count).to eq(1)
    end

    it 'keeps creating new degree nodes if an id is not included' do
      degree_attributes = [{"level"=>"1", "discipline"=>"Computer Science", "name"=>"Master of Science"}]
      subject.degree_attributes = degree_attributes
      subject.save!
      expect(subject.reload.degree.count).to eq(1)

      subject.degree_attributes = degree_attributes
      subject.save!
      expect(subject.reload.degree.count).to eq(2)
    end
  end

end

describe Etd do
  subject { Etd.new }

  it_behaves_like 'with_access_rights'

end
