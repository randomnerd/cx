class AddDonationsToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :donations, :string
  end
end
