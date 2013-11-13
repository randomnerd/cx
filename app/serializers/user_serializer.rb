class UserSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :email, :nickname, :created_at
end
