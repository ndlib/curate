FactoryGirl.define do
  factory :repo_manager do
    username 'admin_user'
    active false
  end

  factory :active_repo_manager, class: RepoManager do
    username 'ndlib'
    active true
  end

  factory :inactive_repo_manager, class: RepoManager do
    username 'inactive-ndlib'
    active false
  end
end
