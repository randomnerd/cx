class AddAlgoToWorkerStats < ActiveRecord::Migration
  def change
    add_column :worker_stats, :algo, :string
    add_index :worker_stats, :algo
  end
end
