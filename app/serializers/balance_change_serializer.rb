class BalanceChangeSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :amount, :balance_id, :created_at, :updated_at, :held, :t_held,
             :comment, :t_amount, :subject_type, :vs_currency, :vs_rate, :txid,
             :currency_id, :address, :block_number

  def vs_currency
    return nil unless object.subject
    c = object.subject.try(:trade_pair).try(:currency)
    m = object.subject.try(:trade_pair).try(:market)
    c.try(:id) == object.balance.currency_id ? m.try(:name) : c.try(:name)
  end

  def vs_rate
    return nil unless object.subject
    c = object.subject.try(:trade_pair).try(:currency)
    m = object.subject.try(:trade_pair).try(:market)
    c.try(:id) == object.balance.currency_id ? object.subject.try(:rate) : 1 * 10 ** 8
  end

  def txid
    return nil unless object.subject
    object.subject.try(:txid)
  end

  def block_number
    return nil unless object.subject
    object.subject.try(:block).try(:number)
  end

  def address
    return nil unless object.subject
    object.subject.try(:address)
  end

  def currency_id
    object.balance.currency_id
  end
end
