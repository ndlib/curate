class CurationConcern::EtdsController < CurationConcern::GenericWorksController
  self.curation_concern_type = Etd

  def setup_form
    super
    curation_concern.build_degree if curation_concern.degree.blank?
  end
end
