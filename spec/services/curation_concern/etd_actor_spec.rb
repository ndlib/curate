require 'spec_helper'

describe CurationConcern::EtdActor do
  # Can't include this spec because ETD doesn't have linked_resources
  #include_examples 'is_a_curation_concern_actor', Etd
  let(:etd) { Etd.new }
  let(:user) { FactoryGirl.create(:user) }
  subject { CurationConcern.actor(etd, user, attributes) }

  describe '#create' do
    let(:attributes) do
      {
        "title"=>"My Etd Title", "alternate_title"=>"", "abstract"=>"Fooba",
        "subject"=>["Stuff"], "country"=>"USA", "advisor"=>["Frank"], "language"=>["English", ""],
        "publisher"=>[""], "coverage_temporal"=>[""], "coverage_spatial"=>[""], "date_created"=>"2013-10-9",
        "note"=>"", "embargo_release_date"=>"", "visibility"=>"restricted", "rights"=>"All rights reserved",
        "date"=>"2013-10-9", "date_approved"=>"2013-10-9","urn"=>"etd-123-abc","creator"=> ["Tony Stark", "Captain America"],
        "degree_attributes" => { "0" => { "degree_level" => "0", "degree_discipline" => "Computer Science", "degree_name" => "BS" } },
        "contributor_attributes" => { "0" => { "contributor" => "Some Body", "role" => "Some Role" }, "1" => { "contributor" => "Some Body Else", "role" => "Some Other Role" } }
      }
    end
    before do
      subject.create
    end

    it "should have set multiple creators" do
      expect(etd).to be_persisted
      reloaded = Etd.find(etd.pid)
      expect(reloaded.creator.size).to eq 2
    end

  end

end
