class AddVirtualToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :virtual, :boolean, default: false
    add_index :currencies, :virtual
  end
end
