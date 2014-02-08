class AddMiningPortToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :mining_port, :integer
    add_index :currencies, :mining_port
  end
end
