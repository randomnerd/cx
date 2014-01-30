class Api::V2::MessagesController < Api::V2::BaseController
  def index
    render json: MultiJson.dump({ messages: Message.recent })
  end

  def create
    msg = current_user.messages.create(permitted_params[:message])
    if msg.valid?
      render json: FastJson.dump_one(msg, true)
    else
      render json: { errors: msg.errors }, status: :unprocessable_entity
    end
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
