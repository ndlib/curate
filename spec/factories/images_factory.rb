FactoryGirl.define do
  factory :image do
    ignore do
      user {FactoryGirl.create(:user)}
    end
    sequence(:title) {|n| "Title #{n}"}
    sequence(:description) {|n| "Description #{n}"}
    rights { Sufia.config.cc_licenses.keys.first }
    date_uploaded { Date.today }
    date_modified { Date.today }
    visibility Sufia::Models::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
    before(:create) { |work, evaluator|
      work.apply_depositor_metadata(evaluator.user.user_key)
      work.creator = evaluator.user.to_s
    }

    factory :private_image do
      visibility Sufia::Models::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
    end
    factory :public_image do
      visibility Sufia::Models::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
    end
  end
end