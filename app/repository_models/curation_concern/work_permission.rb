class CurationConcern::WorkPermission
  def self.create(work, action, people, groups, type='viewer')
    if type == 'editor'
      update_editors(work, people, action)
      update_editor_groups(work, groups, action)
    else
      update_viewers(work, people, action)
      update_viewer_groups(work, groups, action)
    end
    true
  end

  private

    def self.decide_action(attributes_collection, action_type)
      sorted = { remove: [], create: [] }
      return sorted unless attributes_collection
      if attributes_collection.is_a? Hash
        keys = attributes_collection.keys
        attributes_collection = if keys.include?('id') || keys.include?(:id)
          Array(attributes_collection)
        else
          attributes_collection.sort_by { |i, _| i.to_i }.map { |_, attributes| attributes }
        end
      end

      attributes_collection.each do |attributes|
        if attributes['id'].present?
          if has_destroy_flag?(attributes)
            sorted[:remove] << attributes['id']
          elsif action_type == :create || action_type == :update
            sorted[:create] << attributes['id']
          end
        end
      end

      sorted
    end

    private
    def self.has_destroy_flag?(hash)
      ["1", "true"].include?(hash['_destroy'].to_s)
    end

    def self.user(person_id)
      ::User.find_by_repository_id(person_id)
    end

    def self.group(group_id)
      return nil unless group_id.present?
      Hydramata::Group.find(group_id)
    rescue ActiveFedora::ObjectNotFoundError, Rubydora::FedoraInvalidRequest
      nil
    end

    def self.update_editors(work, editors, action)
      collection = decide_action(editors, action)
      work.remove_editors(collection[:remove].map { |u| user(u) }.compact)
      work.add_editors(collection[:create].map { |u| user(u) }.compact)
      work.save!
    end

    def self.update_viewers(work, viewers, action)
      collection = decide_action(viewers, action)
      work.remove_viewers(collection[:remove].map { |u| user(u) }.compact)
      work.add_viewers(collection[:create].map { |u| user(u) }.compact)
      work.save!
    end

    # This is extremely expensive because add_editor_group causes a save each time.
    def self.update_editor_groups(work, editor_groups, action)
      collection = decide_action(editor_groups, action)
      work.remove_editor_groups(collection[:remove].map { |grp| group(grp) }.compact)
      work.add_editor_groups(collection[:create].map { |grp| group(grp) }.compact)
    end

    def self.update_viewer_groups(work, viewer_groups, action)
      collection = decide_action(viewer_groups, action)
      work.remove_viewer_groups(collection[:remove].map { |grp| group(grp) }.compact)
      work.add_viewer_groups(collection[:create].map { |grp| group(grp) }.compact)
    end
end
