class HashrateSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :created_at, :updated_at, :name, :currency_id, :rate, :switchpool

  def name
    object.user.nickname
  end
end
