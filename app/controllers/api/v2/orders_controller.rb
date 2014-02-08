class Api::V2::OrdersController < Api::V2::BaseController
  belongs_to :trade_pair, param: :tradePair, optional: true
  before_filter :authenticate_user!, except: [:index, :show]
  before_filter :no_global_index

  def collection
    @collection ||= end_of_association_chain.active.order(:rate)
  end

  def cancel
    order = current_user.orders.find_by_id(params[:order_id])
    order.try(:cancel)
    render json: order
  end

  def permitted_params
    params.permit(order: [:trade_pair_id, :rate, :amount, :bid])
  end

  def own
    render json: FastJson.dump(collection.where(user_id: current_user.id))
  end

  def no_global_index
    return unless params[:action] == 'index'
    return if params[:tradePair]
    render json: { errors: [{ tradePair: ['Please specify tradePair'] }] }
  end
end
