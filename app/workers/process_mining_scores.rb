class ProcessMiningScores
  include Sidekiq::Worker
  sidekiq_options queue: :currencies, retry: false

  def perform
    top_scrypt = Currency.with_algo('scrypt').by_mining_score.first
    top_sha256 = Currency.with_algo('sha256').by_mining_score.first
    Currency.where(mining_enabled: true).each do |currency|
      currency.process_mining_score
    end
    new_top_scrypt = Currency.with_algo('scrypt').by_mining_score.first
    new_top_sha256 = Currency.with_algo('sha256').by_mining_score.first

    if new_top_scrypt.try(:id) != top_scrypt.try(:id)
      sw_scrypt = Currency.find_by_name('SwitchPool-scrypt')
      sw_scrypt.update_attribute :switched_at, Time.now
      new_top_scrypt.update_attribute :switched_at, Time.now
    end

    if new_top_sha256.try(:id) != top_sha256.try(:id)
      sw_sha256 = Currency.find_by_name('SwitchPool-sha256')
      sw_sha256.update_attribute :switched_at, Time.now
      new_top_sha256.update_attribute :switched_at, Time.now
    end
  end
end
