require 'spec_helper'

module Curate
  describe Configuration do
    its(:default_antivirus_instance) { should respond_to(:call)}
    its(:fedora_integrity_message_delivery) { should respond_to(:call)}
    its(:build_identifier) { should be_an_instance_of String }
    it 'allow for registration of curation_concerns' do
      expect {
        subject.register_curation_concern(:generic_work)
      }.to change{ subject.registered_curation_concern_types }.from([]).to(['GenericWork'])

    end

    it "has a list of the registered classes" do
      expect {
        subject.register_curation_concern(:generic_work)
        subject.register_curation_concern(:image)
      }.to change{ subject.curation_concerns }.from([]).to([GenericWork, Image])
    end

    context '#application_root_url' do
      around(:each) do |example|
        begin
          old_url = subject.application_root_url
          subject.application_root_url = nil
          example.run
        ensure
          subject.application_root_url = old_url
        end
        it 'should require application_root_url to be configured' do
          old_value = subject.application_root_url
          expect {
            subject.application_root_url
          }.to raise_error(RuntimeError)
        end
      end
    end
    context 'override fedora_integrity_message_delivery' do
        it 'raises an exception when the object is invalid' do
          expect {
            subject.fedora_integrity_message_delivery = :bogus_method
          }.to raise_error(RuntimeError)
        end
        Given(:service) { double(call: true) }
        When { subject.fedora_integrity_message_delivery = service }
        Then { subject.fedora_integrity_message_delivery == service }
    end
  end
end
