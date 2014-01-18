class ProcessCurrencies
  include Sidekiq::Worker
  sidekiq_options queue: :currencies, retry: false

  def perform
    Currency.find_each do |currency|
      ProcessCurrency.perform_async(currency.id)
      if currency.mining_enabled
        ProcessPool.perform_async(currency.id)
      end
    end
  end
end
