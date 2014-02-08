class Api::V2::NotificationsController < Api::V2::BaseController
  has_scope :user

  def collection
    @collection ||= end_of_association_chain.recent
  end

  def permitted_params
    params.permit(notification: [:ack])
  end

  def ack_all
    collection.unack.update_all ack: true
    render json: nil
  end

  def del_all
    Notification.where(user:current_user).delete_all
    render json: nil
  end

  protected
  def begin_of_association_chain
    current_user
  end
end
