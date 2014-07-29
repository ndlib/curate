module CurationConcern
  class EtdActor < GenericWorkActor

    def create
      filter_blank_contributor
      super
    end

    def update
      filter_blank_contributor
      super
    end

    private
    def delete_contributor(id)
      contributor = curation_concern.contributor.select{|con| con.id == id}
      contributor.first.destroy unless contributor.first.blank?
    end

    def filter_blank_contributor
      contributors = attributes['contributor_attributes']
      unless contributors.blank?
        contributors.each_key do |contributor_key|
          if !contributors[contributor_key].has_key?('contributor')
            delete_contributor(contributors[contributor_key]['id'])
            contributors.delete(contributor_key)
          elsif contributors[contributor_key]['contributor'].first.blank?
            contributors.delete(contributor_key)
          end
        end
      end
    end
  end
end
