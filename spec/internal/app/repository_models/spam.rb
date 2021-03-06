# Generated via
#  `rails generate curate:work Spam`
require 'active_fedora/base'
require Rails.root.join('app/repository_datastreams/spam_rdf_datastream')
class Spam < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithLinkedContributors
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include CurationConcern::WithEditors
  include CurationConcern::WithViewers

  include ActiveFedora::RegisteredAttributes

  has_metadata "descMetadata", type: SpamRdfDatastream

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  attribute :title, datastream: :descMetadata,
    multiple: false,
    validates: {presence: { message: 'Your work must have a title.' }}

  attribute :rights, datastream: :descMetadata,
    multiple: false,
    validates: {presence: { message: 'You must select a license for your work.' }}

  attribute :created,        datastream: :descMetadata, multiple: false
  attribute :description,    datastream: :descMetadata, multiple: false
  attribute :date_uploaded,  datastream: :descMetadata, multiple: false
  attribute :date_modified,  datastream: :descMetadata, multiple: false
  attribute :available,      datastream: :descMetadata, multiple: false
  attribute :creator,        datastream: :descMetadata, multiple: false
  attribute :content_format, datastream: :descMetadata, multiple: false
  attribute :identifier,     datastream: :descMetadata, multiple: false
  attribute :affiliation,    datastream: :descMetadata, multiple: false
  attribute :organization,   datastream: :descMetadata, multiple: false
  attribute :administrative_unit,   datastream: :descMetadata, multiple: true

  attribute :contributor,            datastream: :descMetadata, multiple: true
  attribute :publisher,              datastream: :descMetadata, multiple: true
  attribute :bibliographic_citation, datastream: :descMetadata, multiple: true
  attribute :source,                 datastream: :descMetadata, multiple: true
  attribute :language,               datastream: :descMetadata, multiple: true
  attribute :extent,                 datastream: :descMetadata, multiple: true
  attribute :requires,               datastream: :descMetadata, multiple: true
  attribute :subject,                datastream: :descMetadata, multiple: true

  attribute :files, multiple: true, form: {as: :file},
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."

end
