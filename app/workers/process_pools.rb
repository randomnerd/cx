class ProcessPools
  @queue = :pools

  def self.perform
    return if Rails.cache.read :pools_processing
    begin
      Rails.cache.write :pools_processing, true
    ensure
      Rails.cache.write :pools_processing, false
    end
  end
end
