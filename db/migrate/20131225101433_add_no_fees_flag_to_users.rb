class AddNoFeesFlagToUsers < ActiveRecord::Migration
  def change
    add_column :users, :no_fees, :boolean
    add_index :users, :no_fees
  end
end
