module Curate
  module UserBehavior
    module Base
      extend ActiveSupport::Concern

      def repository_noid
        Sufia::Noid.noidify(repository_id)
      end

      def repository_noid?
        repository_id?
      end

      def agree_to_terms_of_service!
        update_column(:agreed_to_terms_of_service, true)
      end

      def collections
        Collection.where(Hydra.config[:permissions][:edit][:individual] => user_key)
      end

      def get_value_from_ldap(attribute)
        # override
      end

      def manager?
        is_user_a_manager? && load_manager.active?
      end

      def is_user_a_manager?
        manager_usernames.include?(user_key)
      end

      def manager_usernames
        @manager_usernames ||= RepoManager.usernames
      end

      def name
        read_attribute(:name) || user_key
      end

      def groups
        person.group_pids
      end

      private

      def load_manager
        RepoManager.where(username: user_key).first
      end
    end
  end
end
