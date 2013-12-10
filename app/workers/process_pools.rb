class ProcessPools
  include Sidekiq::Worker

  def perform
    return if Rails.cache.read :pools_processing
    begin
      Rails.cache.write :pools_processing, true
      Currency.all.each do |currency|
      begin
        puts "[#{Time.now}] Processing #{currency.name} mining"
        currency.process_mining
        puts "[#{Time.now}] Processing #{currency.name} mining: done"
      rescue => e
        case e
        when URI::InvalidURIError
          puts "[#{Time.now}] Processing #{currency.name} mining: invalid RPC URL"
        when Errno::ECONNREFUSED
          puts "[#{Time.now}] Processing #{currency.name} mining: connection refused"
        when Errno::EHOSTDOWN
          puts "[#{Time.now}] Processing #{currency.name} mining: host down"
        when Timeout::Error
          puts "[#{Time.now}] Processing #{currency.name} mining: failed to connect"
        when Errno::EHOSTUNREACH
          puts "[#{Time.now}] Processing #{currency.name} mining: host unreachable"
        else
          puts e.inspect
          puts e.backtrace
        end
        next
      end
      end

    ensure
      Rails.cache.write :pools_processing, false
    end
  end
end
