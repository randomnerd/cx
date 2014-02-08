class AddD1aToWorkerStats < ActiveRecord::Migration
  def change
    add_column :worker_stats, :d1a, :integer, limit: 8, default: 0
    add_index :worker_stats, :d1a
  end
end
