class Api::V1::NotificationsController < Api::V1::BaseController
  has_scope :user
  def index
    respond_with end_of_association_chain.recent
  end

  def permitted_params
    params.permit(notification: [:ack])
  end

  def ack_all
    end_of_association_chain.update_all ack: true, updated_at: Time.now
    render json: nil
  end

  def del_all
    end_of_association_chain.destroy_all
    render json: nil
  end

  protected
  def begin_of_association_chain
    current_user
  end
end
