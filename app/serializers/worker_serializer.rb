class WorkerSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :created_at, :updated_at, :name, :pass, :user_id
end
