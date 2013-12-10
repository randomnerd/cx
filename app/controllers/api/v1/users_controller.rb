class Api::V1::UsersController < Api::V1::BaseController
  before_filter :authenticate_user!

  def set_nickname
    resource.set_nickname params[:name]
    render json: resource
  end

  def verify_totp
    totp = params[:totp]
    if resource.totp_verify(totp)
      resource.update_attributes totp_active: !resource.totp_active
      render json: resource
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
end
