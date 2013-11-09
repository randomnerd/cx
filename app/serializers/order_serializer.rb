class OrderSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :trade_pair_id, :amount, :filled, :bid, :rate, :created_at, :complete, :cancelled
end
