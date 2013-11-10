class CreateIncomes < ActiveRecord::Migration
  def change
    create_table :incomes do |t|
      t.integer :amount, limit: 8
      t.integer :currency_id
      t.integer :subject_id
      t.string  :subject_type
      t.timestamps
    end

    add_index :incomes, :currency_id
    add_index :incomes, [:subject_id, :subject_type]
  end
end
