class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :currencies, :algo
    add_index :currencies, :mining_enabled
    add_index :currencies, :mining_skip_switch
    remove_column :currencies, :old_id
    remove_column :trade_pairs, :old_id
  end
end
