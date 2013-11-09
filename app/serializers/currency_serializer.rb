class CurrencySerializer < ActiveModel::Serializer
  attributes :id, :name, :desc, :tx_fee, :tx_conf,
             :blk_conf, :public, :hashrate, :net_hashrate, :last_block_at,
             :mining_enabled, :mining_url, :mining_fee
end
