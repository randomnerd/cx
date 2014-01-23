class Api::V2::UsersController < Api::V2::BaseController
  before_filter :authenticate_user!
  before_filter :check_user

  def check_user
    return if current_user.admin?
    return if resource.id == current_user.id
    raise 'Wrong user ID'
  rescue => e
    render json: { error: e.message }, status: 403
  end

  def set_nickname
    resource.set_nickname params[:name]
    render json: { user: resource }
  end

  def verify_totp
    totp = params[:totp]
    if resource.totp_verify(totp)
      resource.update_attributes totp_active: !resource.totp_active
      render json: { user: resource }
    else
      render json: { error: 'Wrong code' }, status: 403
    end
  end

  def tfa_key
    if resource.totp_active
      render json: { error: 'TFA is already active' }, status: 403
    else
      render json: { key: resource.totp_key }
    end
  end

  def generate_api_keys
    resource.generate_api_keys(true)
    render json: { api_key: resource.api_key }
  end

  def get_api_secret
    if resource.valid_password? params[:password]
      render json: { api_secret: resource.api_secret }
    else
      render json: { error: 'Invalid password' }, status: 403
    end
  end
end
