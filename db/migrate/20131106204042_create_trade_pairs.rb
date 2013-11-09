class CreateTradePairs < ActiveRecord::Migration
  def change
    create_table :trade_pairs do |t|
      t.float :buy_fee
      t.float :sell_fee
      t.integer :last_price
      t.integer :market_id
      t.integer :currency_id
      t.boolean :public
      t.string :url_slug
      t.integer :currency_volume
      t.integer :market_volume
      t.integer :rate_min
      t.integer :rate_max
      t.timestamps
    end
    add_index :trade_pairs, :currency_id
    add_index :trade_pairs, :market_id
    add_index :trade_pairs, :public
    add_index :trade_pairs, :url_slug
  end
end
