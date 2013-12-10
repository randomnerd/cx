class AddOldIdToTradePairs < ActiveRecord::Migration
  def change
    add_column :trade_pairs, :old_id, :string
  end
end
