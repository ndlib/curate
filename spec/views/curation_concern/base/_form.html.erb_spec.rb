require 'spec_helper'

describe 'curation_concern/base/_form.html.erb' do

  let(:person) { FactoryGirl.create(:person_with_user) }
  let(:affiliations) { Double("value") }
  let(:user) { person.user }
  let(:contributor_agreement) { double( :contributor_agreement, param_key: :accept_contributor_agreement, acceptance_value: 'accept', param_value: 'accept' ) }
  context 'New Work' do
    let(:work) { FactoryGirl.build(:generic_work, title: 'work 1') }
    before(:each) do
      controller.stub(:current_user).and_return(user)
      view.stub(:affiliations).and_return([])
      assign(:curation_concern, work)
      render partial: 'form', locals: {curation_concern: work, contributor_agreement: contributor_agreement}
    end
    it 'should have Cancel link which takes to root page' do
      expect(rendered).to have_link('Cancel', href: root_path)
    end
    it 'should have editor legend' do
      expect(rendered).to have_text(t('sufia.work.collaborator.legend'))
      expect(rendered).to have_text(t('sufia.work.collaborator.caption'))
    end
    it 'should have editor in its own fieldset' do
      expect(rendered).to have_selector('fieldset#set-editors div#editors')
    end
    it 'should have labeled editor field' do
      expect(rendered).to have_text(t('sufia.work.collaborator.editor.name'))
    end
    it 'should have inline editor help text' do
      expect(rendered).to have_text(t('sufia.work.collaborator.editor.help'))
    end
    it 'should have groups in their own fieldset' do
      expect(rendered).to have_selector('fieldset#set-groups div#groups')
    end
    it 'should show the editor group name' do
      expect(rendered).to have_text(t('sufia.work.collaborator.editor_group.name'))
    end
    it 'should have group help text' do
      expect(rendered).to have_text(t('sufia.work.collaborator.editor_group.help'))
    end
    it 'should have viewer in its own fieldset' do
      expect(rendered).to have_selector('fieldset#set-viewers div#viewers')
    end
    it 'should have labeled viewer field' do
      expect(rendered).to have_text(t('sufia.work.collaborator.viewer.name'))
    end
    it 'should show the viewer group name' do
      expect(rendered).to have_text(t('sufia.work.collaborator.viewer_group.name'))
    end
    it 'should have group help text' do
      expect(rendered).to have_text(t('sufia.work.collaborator.viewer_group.help'))
    end
  end

  context 'Edit Work' do
    let(:work) {FactoryGirl.build(:generic_work, title: 'work 1') }
    before(:each) do
      work.save
      controller.stub(:current_user).and_return(user)
      assign(:curation_concern, work)
      view.stub(:affiliations).and_return([])
      render partial: 'form', locals: {curation_concern: work, contributor_agreement: contributor_agreement}
    end
    it 'should have Cancel link which takes to show view' do
      expect(rendered).to have_link('Cancel', href: polymorphic_path([:curation_concern, work]))
    end
  end
end
