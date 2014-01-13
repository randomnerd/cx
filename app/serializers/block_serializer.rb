class BlockSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :created_at, :updated_at, :currency_id, :number, :category,
             :reward, :finder, :confirmations, :switchpool
end
