class Api::V1::MessagesController < Api::V1::BaseController
  def index
    respond_with Message.recent
  end

  def permitted_params
    params.permit(message: [:body])
  end
end
