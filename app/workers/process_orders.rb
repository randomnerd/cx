class ProcessOrders
  include Sidekiq::Worker
  sidekiq_options queue: :orders

  def perform(order_id)
    order = Order.find(order_id)
    order.process
  end
end
