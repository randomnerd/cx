class HashrateSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :name, :currency_id, :rate, :switchpool

  def name
    object.user.nickname
  end
end
