class ProcessOrders
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find(order_id)
    order.process
  end
end
