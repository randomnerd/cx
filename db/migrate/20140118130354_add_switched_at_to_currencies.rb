class AddSwitchedAtToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :switched_at, :datetime
  end
end
