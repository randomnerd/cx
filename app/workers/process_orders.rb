class ProcessOrders
  include Sidekiq::Worker
  sidekiq_options queue: :orders, retry: false

  def perform(order_id)
    order = Order.find(order_id)
    order.process
  end
end
