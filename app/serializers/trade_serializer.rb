class TradeSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :created_at, :bid, :rate, :amount, :ask_user_id, :bid_user_id, :trade_pair_id
end
