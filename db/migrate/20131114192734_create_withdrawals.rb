class CreateWithdrawals < ActiveRecord::Migration
  def change
    create_table :withdrawals do |t|
      t.integer :amount, limit: 8, null: false
      t.integer :user_id, null: false
      t.integer :currency_id, null: false
      t.string  :txid
      t.string  :address, null: false
      t.boolean :processed, default: false
      t.boolean :failed, default: false
      t.timestamps
    end

    add_index :withdrawals, [:user_id, :currency_id]
    add_index :withdrawals, :txid
    add_index :withdrawals, :processed
  end
end
