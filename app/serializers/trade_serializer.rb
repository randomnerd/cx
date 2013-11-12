class TradeSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :bid, :rate, :amount, :ask_user_id, :bid_user_id, :trade_pair_id
end
