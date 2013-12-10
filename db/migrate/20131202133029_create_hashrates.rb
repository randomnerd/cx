class CreateHashrates < ActiveRecord::Migration
  def change
    create_table :hashrates do |t|
      t.integer :user_id, null: false
      t.integer :currency_id, null: false
      t.integer :rate, limit: 8, default: 0
      t.timestamps
    end

    add_index :hashrates, [:user_id, :currency_id]
  end
end
