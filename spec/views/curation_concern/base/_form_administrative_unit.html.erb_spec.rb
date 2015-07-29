require 'spec_helper'

describe 'curation_concern/base/_form_administrative_unit.html.erb' do
  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:affiliations) { Double("value") }
  let(:user) { person.user }
  let(:contributor_agreement) { double( :contributor_agreement, param_key: :accept_contributor_agreement, acceptance_value: 'accept', param_value: 'accept' ) }
  let(:form) { double('Form', object_name: 'generic_work') }

  context 'New Work' do
    let(:work) { FactoryGirl.build(:generic_work, title: 'work 1') }
    before(:each) do
      controller.stub(:current_user).and_return(user)
      view.stub(:affiliations).and_return([])
      assign(:curation_concern, work)
      render partial: 'form_administrative_unit', locals: {curation_concern: work, f:form,  button_class: 'btn btn-primary'}
    end

    it 'should have optgroup within select' do
      expect(rendered).to have_select('generic_work_administrative_unit_') do
        with_tag('optgroup', text:'University of Notre Dame')
        with_tag('option', text:'College of Engineering', :with => { :disable => true, :class=>'bold-row'})
      end
    end

    it 'should have valid option within optgroup' do
      expect(rendered).to have_tag('optgroup', :with => { :label => 'University of Notre Dame'}) do
        have_tag('option', :with => { :class=>'bold-row'}, text:'College of Engineering')
      end
      expect(rendered).to have_tag('optgroup', :with => { :label => 'University of Notre Dame'}) do
        with_tag('option', text:'Electrical Engineering')
      end
    end

    it 'should have empty optgroup' do
      expect(rendered).to have_tag('optgroup', :with => { :label => 'University of Notre Dame'}) do
        without_tag('option', :with => { :class=>'bold-row'}, text:'College of Engineering')
      end
    end
  end

  context 'Existing Work' do
    let(:work) { FactoryGirl.build(:generic_work, title: 'work 1') }
    before(:each) do
      work.administrative_unit =['University of Notre Dame::College of Engineering::Electrical Engineering']
      work.save
      controller.stub(:current_user).and_return(user)
      view.stub(:affiliations).and_return([])
      assign(:curation_concern, work)
      render partial: 'form_administrative_unit', locals: {curation_concern: work, f:form,  button_class: 'btn btn-primary'}
    end
    it 'should have option as selected' do
      expect(rendered).to have_tag('option', :with => { :selected => 'selected', :value=>'University of Notre Dame::College of Engineering::Electrical Engineering'})
    end
  end
end
