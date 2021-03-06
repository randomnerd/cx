class CreateTradePairs < ActiveRecord::Migration
  def change
    create_table :trade_pairs do |t|
      t.float :buy_fee, default: 0
      t.float :sell_fee, default: 0
      t.integer :last_price, limit: 8
      t.integer :market_id
      t.integer :currency_id
      t.boolean :public, default: false
      t.string :url_slug
      t.integer :currency_volume, limit: 8, default: 0
      t.integer :market_volume, limit: 8, default: 0
      t.integer :rate_min, limit: 8, default: 0
      t.integer :rate_max, limit: 8, default: 0
      t.timestamps
    end
    add_index :trade_pairs, :currency_id
    add_index :trade_pairs, :market_id
    add_index :trade_pairs, :public
    add_index :trade_pairs, :url_slug
  end
end
