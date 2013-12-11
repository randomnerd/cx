class Hashrate < ActiveRecord::Base
  belongs_to :user
  belongs_to :currency

  scope :active, -> {
    where('hashrates.updated_at > ?', 2.minutes.ago).order('rate desc').limit(15)
  }
  scope :currency_name, -> name {
    joins(:currency).where(currencies: {name: name})
  }

  include PusherSync
  def pusher_channel
    "hashrates-#{self.currency_id}"
  end

  def pusher_update
    return unless self.class.active.include? self
    PusherMsg.perform_async(pusher_channel, "u", pusher_serialize)
  end

  def self.set_rate(currency_id, user_id, hashrate)
    hrate = self.where(user_id: user_id, currency_id: currency_id).first_or_create(
      rate: hashrate
    )
    hrate.rate = hashrate
    hrate.save
  end
end
