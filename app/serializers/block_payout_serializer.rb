class BlockPayoutSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :created_at, :updated_at, :block_id, :user_id, :amount

end
