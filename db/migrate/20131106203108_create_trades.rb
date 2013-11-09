class CreateTrades < ActiveRecord::Migration
  def change
    create_table :trades do |t|
      t.boolean :bid
      t.integer :rate
      t.integer :amount
      t.integer :ask_id
      t.integer :ask_user_id
      t.integer :bid_id
      t.integer :bid_user_id
      t.integer :trade_pair_id
      t.timestamps
    end

    add_index :trades, :trade_pair_id
    add_index :trades, :ask_id
    add_index :trades, :bid_id
    add_index :trades, :bid_user_id
    add_index :trades, :ask_user_id
  end
end
