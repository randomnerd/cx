class ProcessWithdrawals
  include Sidekiq::Worker
  sidekiq_options queue: :withdrawals, retry: false

  def perform(id)
    w = Withdrawal.find(id)
    w.process
  end
end
