# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:firebase_uid) { |n| "firebase-test-uid-#{n}" }
    display_name { "テストユーザー" }
    avatar_url { nil }
  end
end
