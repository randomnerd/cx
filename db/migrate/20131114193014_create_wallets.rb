class CreateWallets < ActiveRecord::Migration
  def change
    create_table :wallets do |t|
      t.integer :user_id, null: false
      t.integer :currency_id, null: false
      t.string  :address, null: false
      t.timestamps
    end

    add_index :wallets, [:user_id, :currency_id]
    add_index :wallets, :address
  end
end
