class Api::V2::OrdersController < Api::V2::BaseController
  belongs_to :trade_pair, param: :tradePair, optional: true
  before_filter :authenticate_user!, except: [:index, :show]

  def index
    if stale? collection.active
      render json: FastJson.dump(collection.active)
    end
  end

  def show
    if stale? resource
      render json: FastJson.dump_one(resource)
    end
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
    order = current_user.orders.find_by_id(params[:order_id])
    order.try(:cancel)
    render json: order
  end

  def permitted_params
    params.permit(order: [:trade_pair_id, :rate, :amount, :bid])
  end

  def own
    render json: FastJson.dump(collection.active.where(user_id: current_user.id))
  end
end
