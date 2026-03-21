# frozen_string_literal: true

FactoryBot.define do
  factory :post do
    user
    body { "hello" }
    brewing_method { nil }

    trait :drip do
      brewing_method { "drip" }
    end

    trait :espresso do
      brewing_method { "espresso" }
    end
  end
end
