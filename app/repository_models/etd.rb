class Etd < ActiveFedora::Base
  include CurationConcern::Work
  include CurationConcern::WithGenericFiles
  include CurationConcern::WithLinkedResources
  include CurationConcern::WithRelatedWorks
  include CurationConcern::Embargoable
  include CurationConcern::WithEditors

  include ActiveFedora::RegisteredAttributes

  has_metadata "descMetadata", type: EtdMetadata

  include CurationConcern::RemotelyIdentifiedByDoi::Attributes

  etd_label = human_readable_type.downcase

  class_attribute :human_readable_short_description
  self.human_readable_short_description = "Deposit a senior thesis, master's thesis, or dissertation."

  def self.human_readable_type
    'ETD'
  end

  has_attributes :degree, :degree_attributes, datastream: :descMetadata, multiple: true
  has_attributes :contributor, :contributor_attributes, datastream: :descMetadata, multiple: true

  def build_degree
    descMetadata.degree = [EtdMetadata::Degree.new(RDF::Repository.new)]
  end

  def build_contributor
    descMetadata.contributor = [EtdMetadata::Contributor.new(RDF::Repository.new)]
  end

  def self.valid_degree_levels
    EtdVocabulary.values_for("degree_level")
  end

  def self.valid_degree_names
    EtdVocabulary.values_for("degree_name")
  end

  def self.valid_degree_disciplines
    EtdVocabulary.values_for("degree_discipline")
  end

   with_options datastream: :descMetadata do |ds|
    ds.attribute :creator,
      multiple: true,
      label: "Author(s)",
      validates: { presence: { message: "Your #{etd_label} must have an Author." } }
    ds.attribute :title,
      label: 'Title',
      hint: "Title of the work as it appears on the title page or equivalent",
      multiple: false,
      validates: { presence: { message: "Your #{etd_label} must have a title." } }
    ds.attribute :alternate_title,
      label: "Alternate title",
      multiple: false
    ds.attribute :subject,
      label: "Subject",
      hint: "The topic of the content of the #{etd_label}.",
      multiple: true,
      validates: { presence: { message: "Your #{etd_label} must have a subject." } }
    ds.attribute :abstract,
      label: "Full text of the abstract",
      multiple: false,
      validates: { presence: { message: "Your #{etd_label} must have an abstract" } }
    ds.attribute :country,
      label: "Country",
      hint: "The country in which the #{etd_label} was originally published or accepted.",
      multiple: false,
      validates: { presence: { message: "Your #{etd_label} must have a country." } }
    ds.attribute :advisor,
      label: "Advisor",
      hint: "Advisor(s) to the thesis author.",
      multiple: true,
      validates: { presence: { message: "Your #{etd_label} must have an advisor." } }
    ds.attribute :date_created,
      default: Date.today.to_s("%Y-%m-%d"),
      label: "Date",
      hint: "The date that appears on the title page or equivalent of the #{etd_label}.",
      multiple: false,
      validates: { presence: { message: "Your #{etd_label} must have a date." } }
    ds.attribute :date_uploaded,
      multiple: false
    ds.attribute :date_modified, 
      multiple: false
    ds.attribute :subject,
      label: "Keyword(s) or phrase(s)",
      hint: "What words or phrases would be helpful for someone searching for your ETD",
      datastream: :descMetadata, multiple: true,
      validates: { presence: { message: "Your #{etd_label} must have a keyword." } }
    ds.attribute :language,
      hint: "What is the language(s) in which you wrote your #{etd_label}?",
      default: ['English'],
      multiple: true,
      validates: { presence: { message: "Your #{etd_label} must have a language." } }
    ds.attribute :rights,
      default: "All rights reserved",
      multiple: false,
      validates: { presence: { message: "You must select a license for your #{etd_label}." } }
    ds.attribute :note,
      label: "Note",
      multiple: false,
      hint: " Additional information regarding the thesis. Example: acceptance note of the department"
    ds.attribute :publisher,
      hint: "An entity responsible for making the resource available. This is typically the group most directly responsible for digitizing and/or archiving the work.",
      multiple: true
    ds.attribute :coverage_temporal,
      multiple: true,
      label: "Coverage Temporal",
      hint: " The overall time frame related to the materials if applicable."
    ds.attribute :coverage_spatial,
      multiple: true,
      label: "Coverage Spatial",
      hint: " The general region that the materials are related to when applicable."
    ds.attribute :identifier,
      multiple: false,
      editable: false
    ds.attribute :format,
      multiple: false,
      editable: false
    ds.attribute :doi,
      multiple: false,
      editable: false
    ds.attribute :urn,
      multiple: false,
      validates: { presence: { message: "Your #{etd_label} must have URN." } }
    ds.attribute :date,
      default: Date.today.to_s("%Y-%m-%d"),
      multiple: false,
      label: "Defense Date",
      validates: { presence: { message: "Your #{etd_label} must have a defense date." } }
    ds.attribute :date_approved,
      multiple: false,
      label: "Approval Date"
  end

  attribute :files,
    multiple: true, form: {as: :file}, label: "Upload Files",
    hint: "CTRL-Click (Windows) or CMD-Click (Mac) to select multiple files."

  #def degree_level
  #  @degree_level ||= [ 'Bachelors', 'Masters', 'Doctorate' ]
  #end
end
