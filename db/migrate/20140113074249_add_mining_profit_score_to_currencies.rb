class AddMiningProfitScoreToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :mining_score, :float
  end
end
