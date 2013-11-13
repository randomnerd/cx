class Api::V1::OrdersController < Api::V1::BaseController
  belongs_to :trade_pair, param: :tradePair, optional: true
  custom_actions resource: [:cancel]

  def index
    respond_with collection.active
  end

  def create
    order = current_user.orders.create(permitted_params[:order])
    render json: {orders: [OrderSerializer.new(order, root: false),]}
  end

  def cancel
    order = Order.find_by_id(params[:order_id])
    order.try(:cancel)
    render json: order
  end

  def permitted_params
    params.permit(order: [:trade_pair_id, :rate, :amount, :bid])
  end
end
