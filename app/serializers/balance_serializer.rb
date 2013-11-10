class BalanceSerializer < ActiveModel::Serializer
  attributes :id, :currency_id, :user_id, :amount, :held, :updated_at
end
