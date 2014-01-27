class BlockSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :currency_id, :number, :category,
             :reward, :finder, :confirmations, :switchpool
end
