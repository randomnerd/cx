class SessionsController < Devise::SessionsController
  def create
    render json: {
      user: UserSerializer.new(current_user, root: false),
      token: form_authenticity_token
    }
  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    render json: {
      'csrf-param' => request_forgery_protection_token,
      'csrf-token' => form_authenticity_token
    }
  end
end
