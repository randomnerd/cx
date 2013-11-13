class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.text :body
      t.string :title
      t.boolean :ack, default: false
      t.integer :user_id
      t.timestamps
    end

    add_index :notifications, [:user_id, :ack]
  end
end
