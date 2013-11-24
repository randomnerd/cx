class PasswordsController < Devise::PasswordsController
  # PUT /resource/password
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?

    if resource.errors.empty?
      sign_in(resource_name, resource)
      render json: UserSerializer.new(resource)
    else
      render json: {errors: resource.errors}, status: 422
    end
  end
end
