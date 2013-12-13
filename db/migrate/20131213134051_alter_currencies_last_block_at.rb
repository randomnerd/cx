class AlterCurrenciesLastBlockAt < ActiveRecord::Migration
  def change
    change_column :currencies, :last_block_at, :datetime
  end
end
