class BalanceChangeSerializer < ActiveModel::Serializer
  attributes :id, :amount, :balance_id, :created_at, :updated_at, :held, :t_held,
             :comment, :t_amount, :subject_type, :txid,
             :currency_id, :address

  def txid
    return nil unless object.subject_type
    return nil unless %(Withdrawal Deposit).include? object.subject_type
    object.subject.try(:txid)
  end

  def address
    return nil unless object.subject_type == 'Withdrawal'
    object.subject.try(:address)
  end

  def currency_id
    object.try(:balance).try(:currency_id)
  end
end
