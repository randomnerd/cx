class AddMiningScoreMarketToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :mining_score_market, :string
  end
end
