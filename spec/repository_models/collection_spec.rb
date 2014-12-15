require 'spec_helper'

describe Collection do
  let(:reloaded_subject) { Collection.find(subject.pid) }

  it 'can be part of a collection' do
    expect(subject.can_be_member_of_collection?(double)).to be_truthy
  end


  it 'can contain another collection' do
    another_collection = FactoryGirl.create(:collection)
    subject.members << another_collection
    subject.members.should == [another_collection]
  end

  it 'cannot contain itself' do
    subject.members << subject
    subject.save
    reloaded_subject.members.should == []
  end

  describe "when visibility is private" do
    it "should not be open_access?" do
      subject.should_not be_open_access
    end
    it "should not be authenticated_only_access?" do
      subject.should_not be_authenticated_only_access
    end
    it "should not be private_access?" do
      subject.should be_private_access
    end
  end

  describe "visibility" do
    it "should have visibility accessor" do
      subject.visibility.should == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end
    it "should have visibility writer" do
      subject.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      subject.should be_open_access
    end
  end

  describe "to_solr on a saved object" do
    let(:solr_doc) {subject.to_solr}
    it "should have a generic_type_sim" do
      solr_doc['generic_type_sim'].should == ['Collection']
    end

  end

  describe '#human_readable_type' do
    it "indicates collection" do
      subject.human_readable_type.should == 'Collection'
    end
  end

  describe '#add_member' do
    it 'adds the member to the collection and returns true' do
      work = FactoryGirl.create(:generic_work, title: 'Work 1')
      subject.add_member(work).should be_truthy
      reloaded_subject.members.should == [work]

      work.reload
      work.collections.should == [subject]
      work.to_solr["collection_sim"].should == [subject.pid]
    end

    it 'returns false if there is nothing to add' do
      subject.add_member(nil).should be_falsey
    end

    it 'returns false if it failed to save' do
      subject.save
      work = FactoryGirl.create(:generic_work)
      subject.stub(:save).and_return(false)
      subject.add_member(work).should be_falsey
      reloaded_subject.members.should == []
    end
  end

  describe '#remove_member' do
    it 'removes the member from the collection and returns true' do
      work = FactoryGirl.create(:generic_work, title: 'Work 2')
      subject.add_member(work)
      subject.members.should == [work]

      work.reload
      work.collections.should == [subject]
      work.to_solr["collection_sim"].should == [subject.pid]

      subject.remove_member(work).should be true
      subject.save!
      reloaded_subject.members.should == []

      work.reload
      work.collections.should == []
      work.to_solr["collection_sim"].should == []
    end

    it 'returns false if there is nothing to delete' do
      subject.remove_member(nil).should be_falsey
    end

    it 'returns false when trying to delete a member with does not belong to the collection' do
      subject.save
      work = FactoryGirl.create(:generic_work)
      subject.remove_member(work).should be_falsey
      reloaded_subject.members.should == []
    end
  end

  describe 'Viewer' do
    let(:person) { FactoryGirl.create(:person_with_user) }
    let(:another_person) { FactoryGirl.create(:person_with_user) }
    let(:collection) { FactoryGirl.create(:collection) }
    describe '#add_viewer' do
      it 'should add viewer' do
        collection.viewers.should == []
        collection.add_viewer(another_person.user)

        collection.save!

        collection.reload
        collection.viewers.should eq [another_person]
        collection.read_users.should eq [another_person.depositor]
      end
    end

    describe '#remove_viewer' do
      before do
        collection.viewers.should == []
        collection.add_viewer(another_person.user)
        collection.save!
        collection.reload
      end
      it 'should remove viewer' do
        collection.remove_viewer(another_person.user)

        collection.reload

        collection.viewers.should == []
        collection.read_users.should_not include(another_person.user.user_key)
      end
    end
  end

  describe 'ViewerGroup' do
    let(:person) { FactoryGirl.create(:person_with_user) }
    let(:user) { person.user }
    let(:group) { FactoryGirl.create(:group, user: user) }
    let(:work) { FactoryGirl.create(:generic_work, user: person.user) }
    let(:collection) { FactoryGirl.create(:collection) }
    describe '#add_viewer_group' do
      it 'should add group' do
        collection.viewer_groups.should == []

        collection.add_viewer_group(group)

        collection.reload

        collection.viewer_groups.should == [group]
        collection.read_groups.should include(group.pid)
        collection.edit_groups.should_not include(group.pid)
      end

      it 'should not add non-group objects' do
        expect { collection.add_viewer_group(work) }.to raise_error ArgumentError
        collection.reload.viewer_groups.should == []
      end
    end

    describe '#remove_viewer_group' do
      before do
        collection.viewer_groups.should == []
        collection.add_viewer_group(group)

        collection.reload
      end

      it 'should remove_viewer_group' do
        collection.remove_viewer_group(group)

        collection.reload

        collection.viewer_groups.should == []
        collection.viewer_groups.should_not include(group.pid)
      end

      it 'should delete relationship when related object is deleted' do
        group_pid = group.pid
        group.destroy

        collection.reload

        collection.read_groups.should_not include(group_pid)
        collection.datastreams['RELS-EXT'].content.to_s.should_not include(group_pid)
      end
    end
  end
end
