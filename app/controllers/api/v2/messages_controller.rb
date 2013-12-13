class Api::V2::MessagesController < Api::V2::BaseController
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

  def destroy
    if current_user.try(:admin?)
      super
    else
      head :unauthorized
    end
  end
end
