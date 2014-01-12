class CurrencySerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :name, :desc, :tx_fee, :tx_conf, :blk_conf, :hashrate,
             :net_hashrate, :last_block_at, :mining_enabled, :mining_url,
             :mining_fee, :donations, :algo, :diff, :updated_at
end
