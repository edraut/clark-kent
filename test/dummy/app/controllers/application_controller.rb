class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  def prepare_filters
    fc_struct = Struct.new(:orders,:departments,:users)
    @filter_collections = fc_struct.new(::Order.all, ::Department.all, ::User.all)
  end

  def current_user
    @current_user ||= ::User.where(id: params[:current_user_id]).first || ::User.where("id is not null").first
    @current_user
  end

  alias_method :effective_user, :current_user

  helper_method :current_user
  helper_method :effective_user
end
