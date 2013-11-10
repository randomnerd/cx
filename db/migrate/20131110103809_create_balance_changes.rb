class CreateBalanceChanges < ActiveRecord::Migration
  def change
    create_table :balance_changes do |t|
      t.integer :amount, default: 0, limit: 8
      t.integer :held,   default: 0, limit: 8
      t.integer :balance_id
      t.integer :subject_id
      t.string  :subject_type
      t.text    :comment
      t.timestamps
    end

    add_index :balance_changes, [:subject_id, :subject_type]
    add_index :balance_changes, :balance_id
  end
end
