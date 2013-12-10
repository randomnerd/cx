class AddAlgoToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :algo, :string
  end
end
