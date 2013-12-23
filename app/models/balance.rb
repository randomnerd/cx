class Balance < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  has_many :balance_changes

  include PusherSync
  def pusher_channel
    "private-balances-#{self.user_id}"
  end

  def rpc_account
    "user-#{self.user_id}"
  end

  scope :currency, -> id { where(currency_id: id) }

  def deposits
    user.deposits.where(currency_id: self.currency_id)
  end

  def withdrawals
    user.withdrawals.where(currency_id: self.currency_id)
  end

  def add_funds(amount, subject, comment = nil)
    self.with_lock do
      increment :amount, amount
      balance_changes.create(
        subject:  subject,
        comment:  comment || "add_funds",
        amount:   amount,
        t_amount: self.amount,
        t_held:   self.held
      ) if save
    end
  end

  def take_funds(amount, subject, comment = nil)
    self.with_lock do
      self.verify!
      return false if self.amount < amount
      decrement :amount, amount
      balance_changes.create(
        subject:  subject,
        comment:  comment || "take_funds",
        amount:   -amount,
        t_amount: self.amount,
        t_held:   self.held
      ) if save
    end
  end


  def lock_funds(lock_amount, subject)
    self.with_lock do
      self.verify!
      return false if self.amount < lock_amount
      decrement :amount,  lock_amount
      increment :held,    lock_amount
      balance_changes.create(
        comment: "lock_funds",
        subject:  subject,
        amount:  -lock_amount,
        held:     lock_amount,
        t_amount: self.amount,
        t_held:   self.held
      ) if save
    end
  end

  def unlock_funds(unlock_amount, subject, move = true)
    self.with_lock do
      if self.held < unlock_amount
        return false if move
        negative = self.held - unlock_amount
        self.add_funds(negative, subject, 'unlock_funds_negative')
        increment :held, negative.abs
      end
      increment :amount,  unlock_amount if move
      decrement :held,    unlock_amount
      balance_changes.create(
        comment: "unlock_funds(move=#{move})",
        subject:  subject,
        amount:   move ? unlock_amount : 0,
        held:    -unlock_amount,
        t_amount: self.amount,
        t_held:   self.held
      ) if save
    end
  end

  def verify(detailed = false)
    v = balance_changes.select('sum(amount) as amount, sum(held) as held').group(:balance_id).order(:balance_id).first
    v.held ||= 0
    v.amount ||= 0
    result = v.amount == self.amount && v.held == self.held
    if detailed
      return {
        held:        v.held,
        valid:       result,
        amount:      v.amount,
        held_diff:   self.held - v.held,
        amount_diff: self.amount - v.amount
      }
    else
      return result
    end
  end

  def verify_each!
    self.with_lock do
      held   = 0
      amount = 0
      self.balance_changes.order(:created_at).find_each do |bc|
        held   += bc.held
        amount += bc.amount
        bc.update_attributes t_amount: amount, t_held: held
      end
      self.update_attributes amount: amount, held: held
    end
  end

  def verify!
    self.with_lock do
      v = self.verify(true)
      update_attributes(amount: v[:amount], held: v[:held]) unless v[:valid]
    end
  end
end
