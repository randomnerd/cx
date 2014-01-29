class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  skip_before_filter :verify_authenticity_token, :if => lambda { request.headers['API-Key'].present? }

  respond_to :html, :json
  helper_method :current_user_json

  before_filter :authorize_by_api_key
  before_filter :update_sanitized_params, if: :devise_controller?

  def update_sanitized_params
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:name, :email, :password, :password_confirmation)}
  end

  def masquerading?
    session[:admin_id].present?
  end
  helper_method :masquerading?

  def authorize_by_api_key
    return unless key  = request.headers['API-Key']
    return unless sign = request.headers['API-Sign']
    raise 'Invalid API-Key' unless user = User.find_by_api_key(key)
    req = request.body.read
    valid_sign = OpenSSL::HMAC.hexdigest('sha512', user.api_secret, req)
    raise 'Invalid API-Sign' unless sign == valid_sign
    sign_in user
    current_user.auth_by_api_key = true
  rescue => e
    render json: {error: e.message, request: req}, status: 403
  end
end
