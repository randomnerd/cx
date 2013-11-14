class CreateAddressBookItems < ActiveRecord::Migration
  def change
    create_table :address_book_items do |t|
      t.string :name
      t.string :address
      t.integer :user_id
      t.integer :currency_id
      t.timestamps
    end

    add_index :address_book_items, [:user_id, :currency_id]
  end
end
