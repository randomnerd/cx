class OrderSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :user_id, :trade_pair_id, :amount, :filled, :bid, :rate, :created_at, :complete, :cancelled, :updated_at
end
