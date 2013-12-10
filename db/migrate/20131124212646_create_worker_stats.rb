class CreateWorkerStats < ActiveRecord::Migration
  def change
    create_table :worker_stats do |t|
      t.integer :worker_id, null: false
      t.integer :currency_id, null: false
      t.integer :diff, default: 0
      t.integer :hashrate, limit: 8, default: 0
      t.integer :accepted, limit: 8, default: 0
      t.integer :rejected, limit: 8, default: 0
      t.integer :blocks,   default: 0
      t.timestamps
    end

    add_index :worker_stats, [:worker_id, :currency_id, :updated_at]
  end
end
