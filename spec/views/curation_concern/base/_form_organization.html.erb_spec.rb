require 'spec_helper'

describe 'curation_concern/base/_form_organization.html.erb' do
  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:affiliations) { Double("value") }
  let(:user) { person.user }
  let(:contributor_agreement) { double( :contributor_agreement, param_key: :accept_contributor_agreement, acceptance_value: 'accept', param_value: 'accept' ) }
  let(:form) { double('Form', object_name: 'generic_work') }
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
  context 'New Work' do
    let(:work) { FactoryGirl.build(:generic_work, title: 'work 1') }
    before(:each) do
      controller.stub(:current_user).and_return(user)
      view.stub(:affiliations).and_return([])
      assign(:curation_concern, work)
      render partial: 'form_organization', locals: {curation_concern: work, f:form,  button_class: 'btn btn-primary'}
    end

    it 'should have optgroup within select' do
      expect(rendered).to have_select('generic_work_organization_') do
        with_tag('optgroup', text:'Humanities')
        with_tag('option', text:'Asian Languages And Literature', :with => { :disable => true, :class=>'bold-row'})
      end
    end

    it 'should have valid option within optgroup' do
      expect(rendered).to have_tag('optgroup', :with => { :label => 'Humanities'}) do
        have_tag('option', :with => { :class=>'bold-row'}, text:'Asian Languages And Literature')
      end
      expect(rendered).to have_tag('optgroup', :with => { :label => 'Humanities'}) do
        with_tag('option', text:'Bogus Department')
        with_tag('option', text:'Chinese Languages')
      end

    end

    it 'should have empty optgroup' do
      expect(rendered).to have_tag('optgroup', :with => { :label => 'Humanities'}) do
        without_tag('option', :with => { :class=>'bold-row'}, text:'Bogus Department')
      end
    end
  end

  context 'Existing Work' do
    let(:work) { FactoryGirl.build(:generic_work, title: 'work 1') }
    before(:each) do
      work.organization =['chinese_languages_and_literature']
      work.save
      controller.stub(:current_user).and_return(user)
      view.stub(:affiliations).and_return([])
      assign(:curation_concern, work)
      render partial: 'form_organization', locals: {curation_concern: work, f:form,  button_class: 'btn btn-primary'}
    end
    it 'should have option as selected' do
      expect(rendered).to have_tag('option', :with => { :selected => 'selected', :value=>'chinese_languages_and_literature'})
    end
  end
end
