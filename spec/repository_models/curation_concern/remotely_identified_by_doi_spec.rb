
require 'spec_helper'

describe CurationConcern::RemotelyIdentifiedByDoi do
  around(:each) do |example|
    class DatastreamClass < ActiveFedora::NtriplesRDFDatastream
      map_predicates do |map|
        map.identifier({in: RDF::DC})
      end
    end
    example.run
    Object.send(:remove_const, :DatastreamClass)
  end

  let(:model) do
    Class.new(ActiveFedora::Base) do
      has_metadata "descMetadata", type: DatastreamClass
      include CurationConcern::RemotelyIdentifiedByDoi::Attributes
    end
  end

  let(:actor){ double(notification_messages: []) }

  describe 'Attributes' do
    subject { model.new }

    it { should respond_to(:identifier) }
    it { should respond_to(:identifier=) }
    it { should respond_to(:existing_identifier) }
    it { should respond_to(:existing_identifier=) }
    it { should respond_to(:doi_assignment_strategy=) }
    it { should respond_to(:doi_assignment_strategy) }

  end

  describe 'MintingBehavior' do
    shared_examples 'minting behavior returning value' do
      it 'should return the returning value' do
        DoiMintingWorker.any_instance.stub(:new).and_return(true)
        DoiMintingWorker.any_instance.stub(:run).and_return(true)
        expect(subject.apply_doi_assignment_strategy(actor, &perform_persistence_block)).to eq(!!returning_value)
      end
    end
    subject { model.new(pid: CurationConcern.mint_a_pid).tap {|m| m.extend CurationConcern::RemotelyIdentifiedByDoi::MintingBehavior } }
    let(:returning_value) { true }
    let(:perform_persistence_block) { lambda {|*| returning_value } }

    context 'with doi_assignment_strategy accessor' do
      let(:doi_assignment_strategy) { nil }

      context '#apply_doi_assignment_strategy' do
        let(:accessor_name) { 'mint_doi' }
        let(:input_existing_identifier) { 'doi: 10.6017/ital.v28i2.3177' }
        let(:expected_existing_identifier) { 'doi:10.6017/ital.v28i2.3177' }
        let(:doi_remote_service) { double(accessor_name: accessor_name) }
        before(:each) do
          subject.existing_identifier = input_existing_identifier
          subject.doi_assignment_strategy = doi_assignment_strategy
          subject.doi_remote_service = doi_remote_service
        end

        context 'with explicit identifier specified' do
          it_behaves_like 'minting behavior returning value'

          let(:doi_assignment_strategy) { described_class::ALREADY_GOT_ONE }
          it 'should allow explicit assignment of identifer' do
            expect {
              subject.apply_doi_assignment_strategy(actor, &perform_persistence_block)
            }.to change(subject, :identifier).from(nil).to(expected_existing_identifier)
          end

          it 'should yield the subject' do
            expect { |b| subject.apply_doi_assignment_strategy(actor, &b) }.to yield_with_args(subject)
          end
        end

        context 'with not now specified' do
          it_behaves_like 'minting behavior returning value'

          let(:doi_assignment_strategy) { described_class::NOT_NOW }

          it 'should return the returning value' do
            expect(subject.apply_doi_assignment_strategy(actor, &perform_persistence_block)).to eq(returning_value)
          end

          it 'should not update identifier' do
            expect {
              subject.apply_doi_assignment_strategy(actor, &perform_persistence_block)
            }.to_not change(subject, :identifier).from(nil)
          end

          it 'should yield the subject' do
            expect { |b| subject.apply_doi_assignment_strategy(actor, &b) }.to yield_with_args(subject)
          end
        end

        context 'with request for minting' do
          let(:notification_message) { double(message_id: :doi_minting, target_pid: 'the_pid') } 
          let(:actor){ double(append_returning_message: true) }

          let(:doi_assignment_strategy) { accessor_name }
          context 'with valid save' do
            it_behaves_like 'minting behavior returning value'
            let(:returning_value) { true }
            it 'should request a minting' do
              DoiMintingWorker.any_instance.stub(:run).and_return(true)
              expect {
                subject.apply_doi_assignment_strategy(actor, &perform_persistence_block)
              }.to_not change(subject, :identifier).from(nil)
              expect(actor).to have_received(:append_returning_message)
            end
          end

          context 'with invalid save' do
            it_behaves_like 'minting behavior returning value'
            let(:returning_value) { false }
            it 'should not request a minting if the perform_persistence_block failed' do
              expect {
                subject.apply_doi_assignment_strategy(actor, &perform_persistence_block)
              }.to_not change(subject, :identifier).from(nil)
            end
          end
        end
      end
    end

    context 'without doi_assignment_strategy accessor' do
      let(:actor){ double(notification_messages: []) }
      it_behaves_like 'minting behavior returning value'

      let(:model) do
        Class.new(ActiveFedora::Base) do
          has_metadata "descMetadata", type: DatastreamClass
        end
      end
      it 'should yield the subject' do
        expect { |b| subject.apply_doi_assignment_strategy(actor, &b) }.to yield_with_args(subject)
      end
    end

  end
end
