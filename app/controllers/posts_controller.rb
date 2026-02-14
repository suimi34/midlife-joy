class PostsController < ApplicationController
  def create
    post = current_user.posts.build(post_params)

    if post.save
      redirect_to feed_path, notice: "投稿しました"
    else
      redirect_to feed_path, inertia: { errors: post.errors }
    end
  end

  private

  def post_params
    params.expect(post: [ :body, :photo ])
  end
end
