class AddAllowNegativeTradingToUsers < ActiveRecord::Migration
  def change
    add_column :users, :allow_negative_trades, :boolean, default: false
    add_column :users, :block_withdrawals, :boolean, default: false
    add_index  :users, :allow_negative_trades
    add_index  :users, :block_withdrawals
  end
end
