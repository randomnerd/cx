class DepositSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :created_at, :updated_at, :amount, :txid, :confirmations,
             :currency_id, :processed
end
