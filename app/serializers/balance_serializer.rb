class BalanceSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :currency_id, :user_id, :amount, :held, :updated_at
end
