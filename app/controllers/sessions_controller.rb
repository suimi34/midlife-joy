class SessionsController < ApplicationController
  skip_before_action :require_login, only: [ :new, :create ]

  def new
    redirect_to feed_path if current_user
    render inertia: "Login"
  end

  def create
    payload = FirebaseTokenVerifier.new(params[:token]).call
    user = User.find_or_create_from_firebase(payload)
    session[:user_id] = user.id
    redirect_to feed_path
  rescue FirebaseTokenVerifier::VerificationError
    redirect_to login_path, inertia: { errors: { token: "認証に失敗しました" } }
  end

  def destroy
    reset_session
    redirect_to login_path
  end
end
