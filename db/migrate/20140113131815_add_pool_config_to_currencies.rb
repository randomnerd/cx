class AddPoolConfigToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :mining_pos, :boolean, default: false
    add_column :currencies, :mining_txmsg, :boolean, default: false
    add_column :currencies, :mining_address, :string
  end
end
