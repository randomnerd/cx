class WorkerStatSerializer < ActiveModel::Serializer
  attributes :id, :created_at, :updated_at, :worker_id, :currency_id,
             :hashrate, :accepted, :rejected, :blocks, :diff, :nickname,
             :switchpool

  def nickname
    object.user.nickname
  end
end
