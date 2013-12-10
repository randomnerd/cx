class AddConfirmOrdersToUsers < ActiveRecord::Migration
  def change
    add_column :users, :confirm_orders, :boolean, default: true
  end
end
