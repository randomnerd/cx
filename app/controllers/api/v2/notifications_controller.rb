class Api::V2::NotificationsController < Api::V2::BaseController
  has_scope :user
  def index
    render json: FastJson.dump(collection.recent)
  end

  def permitted_params
    params.permit(notification: [:ack])
  end

  def ack_all
    end_of_association_chain.unack.each do |n|
      n.update_attribute :ack, true
    end
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
