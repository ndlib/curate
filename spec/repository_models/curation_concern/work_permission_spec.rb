require 'spec_helper'

describe CurationConcern::WorkPermission do
  let(:generic_work) { FactoryGirl.create(:generic_work) }
  let(:invalid_groups) { {"0"=>{"id"=>"true", "_destroy"=>"true", "title"=>"true"}, "1"=>{"id"=>"", "title"=>""}} }
  let(:invalid_editors) { {"0"=>{"id"=>"true", "_destroy"=>"true", "title"=>"true"}, "1"=>{"id"=>"", "title"=>""}} }
  context "non existent group" do
    it "should not complain for adding and removing" do
      expect{
        CurationConcern::WorkPermission.update_groups(generic_work, invalid_groups, "update")
      }.to_not raise_error
    end
  end
  context "non existent editor" do
    it "should not complain for adding and removing" do
      expect{
        CurationConcern::WorkPermission.update_editors(generic_work, invalid_editors, "update")
      }.to_not raise_error
    end
  end
end
