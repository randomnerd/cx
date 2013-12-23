describe Order do
  before do
    @user1 = create :user
    @user2 = create :user
    @trade_pair = create :trade_pair
    @user1.balance_for(@trade_pair.currency_id).add_funds(50*10**8, nil, 'initial')
    @user2.balance_for(@trade_pair.market_id).add_funds(50*10**8, nil, 'initial')
  end

  it 'trades with locking' do
    ask = @user1.orders.create({
      trade_pair: @trade_pair,
      bid: false,
      rate: 0.1 * 10 ** 8,
      amount: 10 * 10 ** 8
    })
    orders = []
    threads = []
    for i in 1..4
      threads << Thread.new(@user2, @trade_pair) do |user, tp|
        order = user.orders.create({
          trade_pair: tp,
          bid: true,
          rate: 0.1 * 10 ** 8,
          amount: 10 * 10 ** 8
        })
        orders << order
        order.process
      end
    end
    threads.each &:join

    ask.reload
    ask.trades.count.should be(1)
    ask.complete.should be_true
    ask.trades.sum(:amount).to_i.should be(ask.amount.to_i)
    @user2.orders.active.count.should be(3)

    # user1 sold 10 currency at 0.1, should have 40 currency and 1 market and 0 held
    @user1.balance_for(@trade_pair.currency_id).amount.should be 40 * 10**8
    @user1.balance_for(@trade_pair.currency_id).held.should be    0
    @user1.balance_for(@trade_pair.market_id).amount.should be    1 * 10**8

    # user2 bought 10 currency at 0.1, should have 10 currency and 49 market and 0 held
    @user2.balance_for(@trade_pair.currency_id).amount.should be 10 * 10**8
    @user2.balance_for(@trade_pair.market_id).held.should be      3 * 10**8
    @user2.balance_for(@trade_pair.market_id).amount.should be   46 * 10**8

    orders.each do |order|
      threads << Thread.new(order) do |order|
        order.cancel
      end
      threads << Thread.new(order) do |order|
        order.cancel
      end
      threads << Thread.new(order) do |order|
        order.cancel
      end
    end
    threads.each &:join

    @user2.balance_for(@trade_pair.market_id).held.should be    0
    @user2.balance_for(@trade_pair.market_id).amount.should be 49 * 10**8
  end

  it 'trades multiple matches with locking' do
    ask = @user1.orders.create({
      trade_pair: @trade_pair,
      bid: false,
      rate: 0.1 * 10 ** 8,
      amount: 10 * 10 ** 8
    })
    ask = @user1.orders.create({
      trade_pair: @trade_pair,
      bid: false,
      rate: 0.01 * 10 ** 8,
      amount: 10 * 10 ** 8
    })
    orders = []
    threads = []
    for i in 1..4
      threads << Thread.new(@user2, @trade_pair) do |user, tp|
        order = user.orders.create({
          trade_pair: tp,
          bid: true,
          rate: 0.1 * 10 ** 8,
          amount: 10 * 10 ** 8
        })
        orders << order
        order.process
      end
    end
    threads.each &:join

    ask.reload
    ask.trades.count.should be(1)
    ask.trades.sum(:amount).to_i.should be(ask.amount.to_i)
    ask.complete.should be_true
    @user2.orders.active.count.should be(2)

    # user1 sold 10 currency at 0.1, should have 40 currency and 1 market and 0 held
    @user1.balance_for(@trade_pair.currency_id).amount.should be 30 * 10**8
    @user1.balance_for(@trade_pair.currency_id).held.should be    0
    @user1.balance_for(@trade_pair.market_id).amount.should be  (1.1 * 10**8).to_i

    # user2 bought 10 currency at 0.1, should have 10 currency and 49 market and 0 held
    @user2.balance_for(@trade_pair.currency_id).amount.should be 20 * 10**8
    @user2.balance_for(@trade_pair.market_id).held.should be      2 * 10**8
    @user2.balance_for(@trade_pair.market_id).amount.should be (46.9 * 10**8).to_i

    orders.each do |order|
      threads << Thread.new(order) do |order|
        order.cancel
      end
      threads << Thread.new(order) do |order|
        order.cancel
      end
      threads << Thread.new(order) do |order|
        order.cancel
      end
    end
    threads.each &:join

    @user2.balance_for(@trade_pair.market_id).held.should be    0
    @user2.balance_for(@trade_pair.market_id).amount.should be (48.9 * 10**8).to_i
  end

  it 'fractional trades with locking' do
    ask = @user1.orders.create({
      trade_pair: @trade_pair,
      bid: false,
      rate: 0.1 * 10 ** 8,
      amount: 10 * 10 ** 8
    })
    orders = []
    threads = []
    for i in 1..4
      threads << Thread.new(@user2, @trade_pair) do |user, tp|
        order = user.orders.create({
          trade_pair: tp,
          bid: true,
          rate: 0.1 * 10 ** 8,
          amount: 3 * 10 ** 8
        })
        orders << order
        order.process
      end
    end
    threads.each &:join

    ask.reload
    ask.trades.count.should be(4)
    ask.trades.sum(:amount).should be(ask.amount)
    ask.complete.should be_true
    @user2.orders.active.count.should be(1)

    # user1 sold 10 currency at 0.1, should have 40 currency and 1 market and 0 held
    @user1.balance_for(@trade_pair.currency_id).amount.should be 40 * 10**8
    @user1.balance_for(@trade_pair.currency_id).held.should be    0
    @user1.balance_for(@trade_pair.market_id).amount.should be    1 * 10**8

    # user2 bought 10 currency at 0.1, should have 10 currency and 49 market and 0 held
    @user2.balance_for(@trade_pair.currency_id).amount.should be 10 * 10**8
    @user2.balance_for(@trade_pair.market_id).held.should be    (0.2 * 10**8).to_i
    @user2.balance_for(@trade_pair.market_id).amount.should be (48.8 * 10**8).to_i

    orders.each do |order|
      threads << Thread.new(order) do |order|
        order.cancel
      end
      threads << Thread.new(order) do |order|
        order.cancel
      end
      threads << Thread.new(order) do |order|
        order.cancel
      end
    end
    threads.each &:join

    @user2.balance_for(@trade_pair.market_id).held.should be    0
    @user2.balance_for(@trade_pair.market_id).amount.should be (49 * 10**8).to_i
  end

end
