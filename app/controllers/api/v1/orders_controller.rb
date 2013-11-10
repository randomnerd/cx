class Api::V1::OrdersController < Api::V1::BaseController
  belongs_to :trade_pair, param: :tradePair, optional: true
  custom_actions resource: [:cancel]
  # has_scope :active, default: true

  def index
    render json: collection.active
  end

  def cancel
    order = Order.find_by_id(params[:order_id])
    order.cancel
    render json: order
  end

  def permitted_params
    params.permit(order: [:trade_pair_id, :rate, :amount, :bid])
  end
end
