class ApplicationController < ActionController::Base
  include Authenticatable

  allow_browser versions: :modern

  inertia_share do
    {
      current_user: current_user&.as_json(only: [ :id, :display_name, :avatar_url ]),
      flash: { notice: flash[:notice], alert: flash[:alert] }
    }
  end
end
