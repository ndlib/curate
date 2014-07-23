class CurationConcern::EtdsController < CurationConcern::GenericWorksController
  self.curation_concern_type = Etd

  def setup_form
    curation_concern.editors << current_user.person if curation_concern.editors.blank?
    curation_concern.editors.build
    curation_concern.editor_groups.build
    curation_concern.build_degree if curation_concern.degree.blank?
    curation_concern.build_contributor if curation_concern.contributor.blank?
  end
end
