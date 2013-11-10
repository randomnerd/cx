class CreateBalances < ActiveRecord::Migration
  def change
    create_table :balances do |t|
      t.integer :currency_id
      t.integer :user_id
      t.integer :amount, default: 0, limit: 8
      t.integer :held, default: 0, limit: 8
      t.timestamps
    end
    add_index :balances, [:user_id, :currency_id]
    add_index :balances, :amount
  end
end
