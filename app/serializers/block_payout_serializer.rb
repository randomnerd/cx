class BlockPayoutSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :block_id, :user_id, :amount

end
