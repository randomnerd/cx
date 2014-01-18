class ProcessCurrency
  include Sidekiq::Worker
  sidekiq_options queue: :currencies, retry: false

  def perform(cid)
    cache_key = "currency_#{cid}_processing"
    return if Rails.cache.read cache_key
    Rails.cache.write cache_key, true
    currency = Currency.find(cid)

    puts "[#{Time.now}] Processing #{currency.name}"
    currency.process_transactions
    puts "[#{Time.now}] Processing #{currency.name}: done"

  rescue => e
    puts e.inspect
    puts e.backtrace
  ensure
    Rails.cache.write cache_key, false
  end
end
