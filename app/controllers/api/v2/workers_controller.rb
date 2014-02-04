class Api::V2::WorkersController < Api::V2::BaseController
  before_filter :authenticate_user!

  protected
  def begin_of_association_chain
    current_user
  end

  def permitted_params
    params.permit(worker: [:name, :pass])
  end
end
