class FeedsController < ApplicationController
  def show
    posts = Post.feed.includes(:user).map do |post|
      post.as_json(only: [ :id, :body, :reactions_count, :created_at ]).merge(
        user: post.user.as_json(only: [ :id, :display_name, :avatar_url ]),
        photo_url: post.photo.attached? ? url_for(post.photo) : nil,
        reacted: current_user.reactions.exists?(post_id: post.id)
      )
    end

    render inertia: "Feed", props: { posts: posts }
  end
end
