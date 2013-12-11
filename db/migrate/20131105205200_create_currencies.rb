class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string  :name
      t.text    :desc
      t.integer :blk_conf
      t.integer :tx_conf
      t.float   :diff
      t.float   :hashrate
      t.float   :net_hashrate
      t.float   :tx_fee
      t.boolean :mining_enabled
      t.boolean :mining_public
      t.string  :mining_url
      t.boolean :public
      t.float   :mining_fee
      t.datetime :last_block_at
      t.string  :user
      t.string  :pass
      t.string  :host
      t.integer :port
      t.timestamps
    end

    add_index :currencies, [:name, :public]
  end
end
