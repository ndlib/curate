# This is hear because it cannot be part of spec_support as other
# Curate based apps would very likely register a :user
FactoryGirl.define do
  factory :user do
    sequence(:email) {|n| "email-#{srand}@test.com" }
    sequence(:name) {|n| "User Named #{n}" }
    agreed_to_terms_of_service true
    user_does_not_require_profile_update true
    password 'a password'
    password_confirmation 'a password'
    sign_in_count 20
  end

  factory :repository_manager_user, parent: :user do
    after(:create) do |user, evaluator|
      RepoManager.create!(username: user.user_key, active: true)
    end
  end

  factory :account do
    user { FactoryGirl.build(:user) }
    sequence(:email) {|n| "email-#{srand}@test.com" }
    initialize_with {|*args|
      new( user )
    }
    after(:create) do |account, evaluator|
      account.save
    end
  end
  factory :repository_manager_account, parent: :account do
    after(:create) do |account, evaluator|
      RepoManager.create!(username: account.user.user_key, active: true)
    end
  end
end
