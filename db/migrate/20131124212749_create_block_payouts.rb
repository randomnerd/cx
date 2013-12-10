class CreateBlockPayouts < ActiveRecord::Migration
  def change
    create_table :block_payouts do |t|
      t.integer :block_id, null: false
      t.integer :user_id, null: false
      t.float   :amount, null: false
      t.boolean :paid, default: false
      t.timestamps
    end

    add_index :block_payouts, [:block_id, :user_id]
  end
end
