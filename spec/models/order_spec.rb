describe Order do
  before do
    @user1 = create :user
    @user2 = create :user
    @trade_pair = create :trade_pair
    @user1.balance_for(@trade_pair.currency_id).add_funds(50*10**8, nil, 'initial')
    @user2.balance_for(@trade_pair.market_id).add_funds(50*10**8, nil, 'initial')
  end

  it 'does the trade' do
    ask = @user1.orders.create({
      trade_pair: @trade_pair,
      bid: false,
      rate: 0.1 * 10 ** 8,
      amount: 10 * 10 ** 8
    })
    orders = []
    threads = []
    for i in 1..4
      orders << @user2.orders.create({
        trade_pair: @trade_pair,
        bid: true,
        rate: 0.1 * 10 ** 8,
        amount: 10 * 10 ** 8
      })
    end

    orders.each do |order|
      threads << Thread.new(order) do |order|
        order.reload.process
      end
    end
    threads.each &:join
    ask.reload.trades.count.should be(1)
    Order.active.count.should be(3)
  end
end
