class Api::V2::OrdersController < Api::V2::BaseController
  belongs_to :trade_pair, param: :tradePair, optional: true
  has_scope :bid
  before_filter :authenticate_user!, except: [:index, :show, :book]
  before_filter :no_global_index
  before_filter :set_bid_both

  def collection
    @collection ||= end_of_association_chain.active.order(rate: :asc)
  end

  def book
    pair = TradePair.find params[:tradePair]
    book = @both ? pair.order_book_both : pair.order_book(@bid)
    render json: { order_book: book }
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
    return unless %w(index book).include? params[:action]
    return if params[:tradePair]
    render json: { errors: [{ tradePair: ['Please specify tradePair'] }] }
  end

  def set_bid_both
    @both = !params[:bid].present?
    @bid = params[:bid] == 'true'
  end
end
