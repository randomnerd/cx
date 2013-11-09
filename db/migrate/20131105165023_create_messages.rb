class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :body
      t.references :user
      t.boolean :system

      t.timestamps
    end
  end
end
