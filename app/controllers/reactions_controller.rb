class ReactionsController < ApplicationController
  def create
    current_user.reactions.find_or_create_by!(post_id: params[:post_id])
    redirect_to feed_path
  end

  def destroy
    current_user.reactions.find_by(post_id: params[:id])&.destroy
    redirect_to feed_path
  end
end
