class AddOldIdToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :old_id, :string
  end
end
