class RegistrationsController  < ApplicationController
  respond_to :json

  def create
    user = User.new(user_params)

    if user.save
      render json: {
        user: UserSerializer.new(user, root: false),
        token: form_authenticity_token
      }
    else
      warden.custom_failure!
      render :json => user.errors, :status=>422
    end
  end

  def user_params
    params.require(:user).permit(:email, :password)
  end

end
