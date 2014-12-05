module CurationConcern
  module WithViewers
    extend ActiveSupport::Concern

    included do
      before_destroy :clear_associations
    end

    def add_viewer_group(group)
      raise ArgumentError, "parameter is #{group.inspect}, expected a kind of Hydramata::Group" unless group.is_a?(Hydramata::Group)
      viewer_groups << group
      self.permissions_attributes = [{ name: group.pid, access: 'read',
                                       type: 'group' }]
      self.save!
      group.view_works << self
      group.save!
    end

    # @param groups [Array<Hydramata::Group>] a list of groups to add
    def add_viewer_groups(groups)
      groups.each do |g|
        add_viewer_group(g)
      end
    end

    def remove_viewer_group(group)
      return unless read_groups.include?(group.pid)
      read_groups.delete(group)
      self.read_groups = read_groups - [group.pid]
      self.save!
      group.view_works.delete(self)
      group.save!
    end

    # @param groups [Array<Hydramata::Group>] a list of users to remove
    def remove_viewer_groups(groups)
      groups.each do |g|
        remove_viewer_group(g)
      end
    end

    # @param user [User] the user account you want to grant read access to.
    def add_viewer(user)
      raise ArgumentError, "parameter is #{user.inspect}, expected a kind of User" unless user.is_a?(User)
      viewers << user.person
      self.permissions_attributes = [{ name: user.user_key, access: 'read', type: 'person' }] unless depositor == user.user_key
    end

    # @param users [Array<User>] a list of users to add
    def add_viewers(users)
      users.each do |u|
        add_viewer(u)
      end
    end

    # @param user [User] the user account you want to revoke read access for.
    def remove_viewer(user)
      remove_candidate_viewer(user)
    end

    # @param users [Array<User>] a list of users to remove
    def remove_viewers(users)
      users.each do |u|
        remove_viewer(u)
      end
    end

    private

      def clear_associations
        clear_viewer_groups
        clear_viewers
      end

      def clear_viewer_groups
        viewer_groups.each do |viewer_group|
          remove_viewer_group(viewer_group)
        end
      end

      def clear_viewers
        viewers.each do |viewer|
          remove_candidate_viewer(User.find_by_repository_id(viewer.pid))
        end
      end

      def remove_candidate_viewer(user)
        viewers.delete(user.person)
        self.read_users = read_users - [user.user_key]
        user.person.view_works.delete(self)
      end
  end
end
