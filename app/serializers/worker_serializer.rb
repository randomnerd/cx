class WorkerSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :name, :pass, :user_id
end
