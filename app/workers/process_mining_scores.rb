class ProcessMiningScores
  include Sidekiq::Worker
  sidekiq_options queue: :currencies, retry: false

  def perform
    Currency.where(public: true, mining_enabled: true).each do |currency|
      currency.process_mining_score
    end
  end
end
