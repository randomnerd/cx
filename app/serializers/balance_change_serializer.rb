class BalanceChangeSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :amount, :held, :balance_id, :created_at, :updated_at,
             :comment, :t_amount, :t_held, :subject_type, :vs_currency, :vs_rate

  def vs_currency
    return nil unless object.subject
    object.subject.trade_pair.currency.name
  end

  def vs_rate
    return nil unless object.subject
    object.subject.rate
  end
end
