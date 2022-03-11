FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "name#{n}" }
    sequence(:email) { |n| "user#{n}@example.com" }
    password_digest { User.digest('password') }
    admin { false }
    activated { true }
    activated_at { Time.zone.now }
  end

  trait :with_micropost do
    after(:create) { |user| create(:micropost, user: user) }
  end

  trait :admin do
    admin { true }
  end

  trait :unactivated do
    activated { false }
    activated_at { nil }
  end
end
