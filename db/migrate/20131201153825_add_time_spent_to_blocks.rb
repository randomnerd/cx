class AddTimeSpentToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :time_spent, :integer
  end
end
