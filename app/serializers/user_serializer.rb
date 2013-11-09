class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :nickname, :created_at
end
