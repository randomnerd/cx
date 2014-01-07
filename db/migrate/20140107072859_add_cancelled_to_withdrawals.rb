class AddCancelledToWithdrawals < ActiveRecord::Migration
  def change
    add_column :withdrawals, :cancelled, :boolean, default: false
    add_index :withdrawals, :cancelled
  end
end
