require 'spec_helper'

describe 'Creating an etd' do
  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:user) { person.user }

  before do
    EtdVocabulary.new(field_type: "degree_level", field_value: 2).save
    EtdVocabulary.new(field_type: "degree_discipline", field_value: "Computer Science").save
    EtdVocabulary.new(field_type: "degree_name", field_value: "PhD").save
  end
  it "should allow me to attach the link on the create page" do
    login_as(user)
    visit root_path
    click_link "add-content"
    classify_what_you_are_uploading 'Etd'
    within '#new_etd' do
      fill_in "Title", with: "umami sartorial Williamsburg church-key"
      fill_in "URN", with: "etd-abcd-xyz123"
      fill_in "Abstract", with: "Some stuff"
      fill_in "Country", with: "Belgium"
      fill_in "Author", with: "Tony Stark"
      fill_in "Advisor", with: "Marcy Holmes"
      fill_in "Subject", with: "Paleoethnography"
      fill_in "Submission Date", with: "2013 October 4"
      select(2, from: "etd_degree_attributes_0_level")
      select("Computer Science", from: "etd_degree_attributes_0_discipline")
      select("PhD", from: "etd_degree_attributes_0_name")
      select(Sufia.config.cc_licenses.keys.first.dup, from: I18n.translate('sufia.field_label.rights'))
      check("I have read and accept the contributor license agreement")
      click_button("Create Etd")
    end

    click_button 'keyword-search-submit'
    # then I should find it in the search results.
    fill_in 'Search Curate', with: 'sartorial umami'
    click_button 'keyword-search-submit'
    within('#documents') do
      expect(page).to have_link('umami sartorial Williamsburg church-key') #title
    end
  end
end

describe 'Viewing an ETD that is private' do
  let(:user) { FactoryGirl.create(:user) }
  let(:work) { FactoryGirl.create(:private_etd, title: "Sample work" ) }

  it 'should show a stub indicating we have the work, but it is private' do
    login_as(user)
    visit curation_concern_etd_path(work)
    page.should have_content('Unauthorized')
    page.should have_content('The etd you have tried to access is private')
    page.should have_content("ID: #{work.pid}")
    page.should_not have_content("Sample work")
  end
end



