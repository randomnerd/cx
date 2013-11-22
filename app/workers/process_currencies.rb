class ProcessCurrencies
  include Sidekiq::Worker

  def perform
    return if Rails.cache.read :currencies_processing
    Rails.cache.write :currencies_processing, true
    Currency.all.each do |currency|
      begin
        puts "[#{Time.now}] Processing #{currency.name}"
        currency.with_lock do
          currency.process_transactions
        end
        puts "[#{Time.now}] Processing #{currency.name}: done"
      rescue => e
        case e
        when URI::InvalidURIError
          puts "[#{Time.now}] Processing #{currency.name}: invalid RPC URL"
        when Errno::ECONNREFUSED
          puts "[#{Time.now}] Processing #{currency.name}: connection refused"
        when Errno::EHOSTDOWN
          puts "[#{Time.now}] Processing #{currency.name}: host down"
        when Timeout::Error
          puts "[#{Time.now}] Processing #{currency.name}: failed to connect"
        when Errno::EHOSTUNREACH
          puts "[#{Time.now}] Processing #{currency.name}: host unreachable"
        else
          puts e.inspect
          puts e.backtrace
        end
        next
      end
    end
  rescue => e
    puts e.inspect
  ensure
    Rails.cache.write :currencies_processing, false
  end
end
