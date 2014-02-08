class AddNameToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :name, :string
    add_index :messages, :created_at
  end
end
