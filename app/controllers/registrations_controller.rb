class RegistrationsController < Devise::RegistrationsController
  respond_to :json

  def create
    user = User.new(user_params)

    if user.save
      sign_in user
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

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if update_resource(resource, account_update_params)
      sign_in resource_name, resource, :bypass => true
      render json: UserSerializer.new(resource)
    else
      clean_up_passwords resource
      render json: {errors: resource.errors}, status: 422
    end
  end
end
