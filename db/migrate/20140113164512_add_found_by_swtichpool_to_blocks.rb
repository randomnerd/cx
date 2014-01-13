class AddFoundBySwtichpoolToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :switchpool, :boolean, default: false
    add_index :blocks, :switchpool
  end
end
