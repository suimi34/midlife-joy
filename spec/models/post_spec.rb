# frozen_string_literal: true

require "rails_helper"

RSpec.describe Post, type: :model do
  let(:user) { create(:user) }

  it "is valid with nil brewing_method" do
    post = user.posts.build(body: "hello")
    expect(post).to be_valid
  end

  it "is valid with blank brewing_method" do
    post = user.posts.build(body: "hello", brewing_method: "")
    expect(post).to be_valid
  end

  it "is valid with allowed brewing_method" do
    post = user.posts.build(body: "hello", brewing_method: "drip")
    expect(post).to be_valid
  end

  it "is invalid with unknown brewing_method" do
    post = user.posts.build(body: "hello", brewing_method: "not_a_method")
    expect(post).not_to be_valid
    expect(post.errors[:brewing_method]).not_to be_empty
  end
end
