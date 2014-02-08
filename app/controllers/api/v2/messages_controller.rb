class Api::V2::MessagesController < Api::V2::BaseController
  def collection
    @collection ||= end_of_association_chain.recent
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
