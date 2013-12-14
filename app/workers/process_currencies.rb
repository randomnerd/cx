class ProcessCurrencies
  include Sidekiq::Worker

  def perform
    Currency.all.each do |currency|
      ProcessCurrency.perform_async(currency.id)
      if currency.mining_enabled
        ProcessPool.perform_async(currency.id)
      end
    end
  end
end
