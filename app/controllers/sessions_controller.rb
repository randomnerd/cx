class SessionsController < Devise::SessionsController
  def create
    if current_user
      render json: {
        user: UserSerializer.new(current_user),
        token: form_authenticity_token
      }
    else
      head :unauthorized
    end
  end

  def destroy
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json {
        render json: {
          'csrf-param' => request_forgery_protection_token,
          'csrf-token' => form_authenticity_token
        }
      }
    end
  end
end
