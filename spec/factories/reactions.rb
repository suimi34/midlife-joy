# frozen_string_literal: true

FactoryBot.define do
  factory :reaction do
    user
    post
  end
end
