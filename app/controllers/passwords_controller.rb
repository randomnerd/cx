class PasswordsController < Devise::PasswordsController
  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.update_attribute :reset_password_token, nil
      sign_in(resource_name, resource)
      render json: UserSerializer.new(resource, root: false)
    else
      render json: {errors: resource.errors}, status: 422
    end
  end
end
