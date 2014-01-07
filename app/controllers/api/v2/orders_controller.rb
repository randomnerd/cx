class Api::V2::OrdersController < Api::V2::BaseController
  belongs_to :trade_pair, param: :tradePair, optional: true
  custom_actions resource: [:cancel]

  def index
    render json: FastJson.dump(collection.active)
  end

  def create
    order = current_user.orders.create(permitted_params[:order])
    if order.persisted?
      render json: FastJson.dump_one(order)
    else
      render json: {errors: order.errors}, status: :unprocessable_entity
    end
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
