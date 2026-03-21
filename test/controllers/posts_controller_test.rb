# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionController::TestCase
  setup do
    @user = User.create!(firebase_uid: "posts-ctrl-#{SecureRandom.hex(8)}")
    session[:user_id] = @user.id
  end

  test "create succeeds with blank brewing_method" do
    assert_difference -> { Post.count }, 1 do
      post :create, params: { post: { body: "hello world", brewing_method: "" } }
    end
    assert_redirected_to feed_path
  end

  test "create succeeds with valid brewing_method" do
    assert_difference -> { Post.count }, 1 do
      post :create, params: { post: { body: "hello world", brewing_method: "espresso" } }
    end
    assert_redirected_to feed_path
  end

  test "create fails with invalid brewing_method" do
    assert_no_difference -> { Post.count } do
      post :create, params: { post: { body: "hello world", brewing_method: "invalid" } }
    end
    assert_redirected_to feed_path
  end
end
