class MessageSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :body, :name, :created_at, :updated_at, :system
end
