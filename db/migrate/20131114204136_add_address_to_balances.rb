class AddAddressToBalances < ActiveRecord::Migration
  def change
    add_column :balances, :deposit_address, :string
    add_index :balances, :deposit_address
  end
end
