class CreateBlocks < ActiveRecord::Migration
  def change
    create_table :blocks do |t|
      t.integer :currency_id, null: false
      t.integer :user_id, null: false
      t.integer :number, null: false
      t.string  :txid, null: false
      t.integer :reward, limit: 8, null: false
      t.string  :finder
      t.integer :confirmations, null: false
      t.string  :category, null: false
      t.float   :diff, default: 0
      t.boolean :paid, default: false
      t.timestamps
    end

    add_index :blocks, [:user_id, :currency_id]
    add_index :blocks, [:currency_id, :paid, :category]
    add_index :blocks, :txid
  end
end
