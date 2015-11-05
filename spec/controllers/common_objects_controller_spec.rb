require 'spec_helper'

describe CommonObjectsController do
  let(:user) { FactoryGirl.create(:user) }
  let(:another_user) { FactoryGirl.create(:user) }
  let(:visibility) { nil }
  let(:curation_concern) {
    FactoryGirl.create_generic_file(:generic_work, user) { |gf|
      gf.visibility = visibility
    }
  }
  describe '#show' do
    let(:template_for_success) { 'show' }
    let(:template_for_restricted_object) { 'layouts/common_objects' }

    describe '"Open Access" object' do
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
      it 'renders for unauthenticated person' do
        get :show, id: curation_concern.to_param
        response.status.should == 200
        expect(response).to render_template(template_for_success)
      end

      it 'renders for the creator' do
        sign_in(user)
        get :show, id: curation_concern.to_param
        response.status.should == 200
        expect(response).to render_template(template_for_success)
      end

      it 'renders for the another user' do
        sign_in(another_user)
        get :show, id: curation_concern.to_param
        response.status.should == 200
        expect(response).to render_template(template_for_success)
      end
    end

    describe '"Restricted" object' do
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      it 'redirect for unauthenticated person' do
        get :show, id: curation_concern.to_param
        response.status.should == 401
        expect(response).to render_template(template_for_restricted_object)
      end

      it 'renders for the creator' do
        sign_in(user)
        get :show, id: curation_concern.to_param
        response.status.should == 200
        expect(response).to render_template(template_for_success)
      end

      it 'renders for the creator' do
        sign_in(another_user)
        get :show, id: curation_concern.to_param
        response.status.should == 401
        expect(response).to render_template(template_for_restricted_object)
      end
    end

    describe '"Institution Only" object' do
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
      it 'does not display for unauthenticated person' do
        get :show, id: curation_concern.to_param
        response.status.should == 401
        expect(response).to render_template(template_for_restricted_object)
      end

      it 'renders for the creator' do
        sign_in(user)
        get :show, id: curation_concern.to_param
        response.status.should == 200
        expect(response).to render_template(template_for_success)
      end

      it 'renders for the creator' do
        sign_in(another_user)
        get :show, id: curation_concern.to_param
        response.status.should == 200
        expect(response).to render_template(template_for_success)
      end
    end
  end

  describe '#show_stub_information' do
    let(:template_for_success) { 'show_stub_information' }
    describe '"Open Access" object' do
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC }
      it 'renders rudimentary information' do
        get :show_stub_information, id: curation_concern.to_param
        response.status.should == 200
        expect(response).to render_template(template_for_success)
      end
    end
    describe '"Restricted" object' do
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE }
      it 'renders rudimentary information' do
        get :show_stub_information, id: curation_concern.to_param
        response.status.should == 200
        expect(response).to render_template(template_for_success)
      end
    end
    describe '"Institution Only" object' do
      let(:visibility) { Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED }
      it 'renders rudimentary information' do
        get :show_stub_information, id: curation_concern.to_param
        response.status.should == 200
        expect(response).to render_template(template_for_success)
      end
    end
  end
end
