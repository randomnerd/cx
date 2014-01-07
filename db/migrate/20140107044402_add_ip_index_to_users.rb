class AddIpIndexToUsers < ActiveRecord::Migration
  def change
    add_index :users, :current_sign_in_ip
    add_index :users, :last_sign_in_ip
  end
end
