class WorkerStatSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :created_at, :updated_at, :worker_id, :currency_id,
             :hashrate, :accepted, :rejected, :blocks, :diff, :nickname

  def nickname
    object.worker.user.nickname
  end
end
