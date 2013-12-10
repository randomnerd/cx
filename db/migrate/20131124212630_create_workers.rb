class CreateWorkers < ActiveRecord::Migration
  def change
    create_table :workers do |t|
      t.integer :user_id, null: false
      t.string  :name, null: false
      t.string  :pass, null: false
      t.timestamps
    end

    add_index :workers, :user_id
    add_index :workers, [:name, :pass]
  end
end
