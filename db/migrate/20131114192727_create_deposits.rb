class CreateDeposits < ActiveRecord::Migration
  def change
    create_table :deposits do |t|
      t.integer :confirmations, default: 0
      t.integer :amount, limit: 8, null: false
      t.integer :wallet_id, null: false
      t.integer :user_id, null: false
      t.integer :currency_id, null: false
      t.string  :txid, null: false
      t.boolean :processed, default: false
      t.timestamps
    end

    add_index :deposits, [:user_id, :wallet_id, :currency_id]
    add_index :deposits, :txid
    add_index :deposits, [:processed, :confirmations]
  end
end
