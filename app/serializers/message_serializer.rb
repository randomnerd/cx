class MessageSerializer < ActiveModel::Serializer
  attributes :id, :body, :name, :created_at
end
