class Balance < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency
  has_many :balance_changes

  after_create :push_create
  after_update :push_update
  after_destroy :push_delete

  scope :currency, -> id { where(currency_id: id) }

  def add_funds(amount, subject)
    self.with_lock do
      increment :amount, amount
      balance_changes.create(
        subject:  subject,
        amount:   amount
      ) if save
    end
  end

  def lock_funds(lock_amount, subject)
    self.with_lock do
      return false if self.amount < lock_amount
      decrement :amount, lock_amount
      increment :held,    lock_amount
      balance_changes.create(
        subject:  subject,
        amount:  -lock_amount,
        held:     lock_amount
      ) if save
    end
  end

  def unlock_funds(unlock_amount, subject, move = true)
    self.with_lock do
      return false if self.held < unlock_amount
      increment :amount, unlock_amount if move
      decrement :held,    unlock_amount
      balance_changes.create(
        subject:  subject,
        amount:   unlock_amount,
        held:    -unlock_amount
      ) if save
    end
  end

  def push_create
    Pusher["private-balances-#{user_id}"].trigger_async('balance#new',
      BalanceSerializer.new(self, root: false))
  end

  def push_update
    Pusher["private-balances-#{user_id}"].trigger_async('balance#update',
      BalanceSerializer.new(self, root: false))
  end

  def push_delete
    Pusher["private-balances-#{user_id}"].trigger_async('balance#delete',
      BalanceSerializer.new(self, root: false))
  end

end
