class BalanceChangeSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :amount, :held, :balance_id, :subject_type
end
