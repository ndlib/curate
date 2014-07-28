module CurationConcern
  class EtdActor < GenericWorkActor

    def create
      contributors = attributes['contributor_attributes']
      unless contributors.blank?
        contributors.each_key do |contributor_key|
          unless contributors[contributor_key].has_key?('contributor')
            contributors.delete(contributor_key)
          end
        end
      end
      super
    end

    def update
      contributors = attributes['contributor_attributes']
      contributors.each_key do |contributor_key|
        unless contributors[contributor_key].has_key?('contributor')
          delete_contributor(contributors[contributor_key]['id'])
        end
      end
      super
    end

    private
    def delete_contributor(id)
      contributor = curation_concern.contributor.select{|con| con.id == id}
      contributor.first.destroy
    end
  end
end
