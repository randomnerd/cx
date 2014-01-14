class AddSwitchpoolFlags < ActiveRecord::Migration
  def change
    add_column :worker_stats, :switchpool, :boolean, default: false
    add_column :hashrates, :switchpool, :boolean, default: false
    add_index :worker_stats, :switchpool
    add_index :hashrates, :switchpool
  end
end
