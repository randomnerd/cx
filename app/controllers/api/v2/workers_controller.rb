class Api::V2::WorkersController < Api::V2::BaseController
  before_filter :authenticate_user!

  def create
    record = end_of_association_chain.create(permitted_params[:worker])
    if record.persisted?
      render json: {worker: WorkerSerializer.new(record)}
    else
      render json: {errors: record.errors}, status: :unprocessable_entity
    end
  end

  protected
  def begin_of_association_chain
    current_user
  end

  def permitted_params
    params.permit(worker: [:name, :pass])
  end
end
