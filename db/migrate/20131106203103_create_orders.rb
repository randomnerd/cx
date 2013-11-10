class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :amount, limit: 8
      t.integer :rate, limit: 8
      t.boolean :bid
      t.boolean :cancelled, default: false
      t.boolean :complete, default: false
      t.float   :fee, default: 0
      t.integer :filled, default: 0, limit: 8
      t.references :trade_pair
      t.references :user
      t.timestamps
    end
    add_index :orders, [:user_id, :trade_pair_id, :rate, :complete, :cancelled, :bid], name: 'orders_index'
  end
end
