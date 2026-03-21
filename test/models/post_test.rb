# frozen_string_literal: true

require "test_helper"

class PostTest < ActiveSupport::TestCase
  setup do
    @user = User.create!(firebase_uid: "post-test-#{SecureRandom.hex(8)}")
  end

  test "valid with nil brewing_method" do
    post = @user.posts.build(body: "hello")
    assert post.valid?
  end

  test "valid with blank brewing_method" do
    post = @user.posts.build(body: "hello", brewing_method: "")
    assert post.valid?
  end

  test "valid with allowed brewing_method" do
    post = @user.posts.build(body: "hello", brewing_method: "drip")
    assert post.valid?
  end

  test "invalid with unknown brewing_method" do
    post = @user.posts.build(body: "hello", brewing_method: "not_a_method")
    assert_not post.valid?
    assert_predicate post.errors[:brewing_method], :any?
  end
end
