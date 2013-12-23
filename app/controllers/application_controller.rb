class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  respond_to :html, :json
  helper_method :current_user_json

  before_filter :update_sanitized_params, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:name, :email, :password, :password_confirmation)}
  end

  def masquerading?
    session[:admin_id].present?
  end
  helper_method :masquerading?
end
