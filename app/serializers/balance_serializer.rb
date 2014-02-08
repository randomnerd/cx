class BalanceSerializer < ActiveModel::Serializer
  attributes :id, :currency_id, :user_id, :amount, :held, :updated_at,
             :deposit_address, :currency_name

  def currency_name
    object.currency.name
  end
end
