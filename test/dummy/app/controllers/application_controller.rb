class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def current_user

    @current_user ||= ::User.where(id: params[:current_user_id]).first || ::User.where("id is not null").first
    @current_user
  end

  helper_method :current_user
end
