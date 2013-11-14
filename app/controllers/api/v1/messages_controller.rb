class Api::V1::MessagesController < Api::V1::BaseController
  def index
    respond_with Message.recent
  end

  def create
    msg = current_user.messages.create(permitted_params[:message])
    render json: {messages: [MessageSerializer.new(msg, root: false)]}
  end

  def permitted_params
    params.permit(message: [:body])
  end
end
