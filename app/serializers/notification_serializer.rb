class NotificationSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :title, :body, :created_at, :updated_at, :ack, :user_id
end
