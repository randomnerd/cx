class DepositSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :amount, :txid, :confirmations,
             :currency_id, :processed
end
