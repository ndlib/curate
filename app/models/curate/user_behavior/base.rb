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
        return false unless repository_manager_record.present?
        repository_manager_record.active?
      end

      def repository_manager?
        repository_manager_record.present?
      end

      def name
        read_attribute(:name) || user_key
      end

      def groups
        person.group_pids
      end

      private

      def repository_manager_record
        RepoManager.find_by(username: user_key)
      end
    end
  end
end
