class AddTotpKeyToUsers < ActiveRecord::Migration
  def change
    add_column :users, :totp_key, :string
    add_column :users, :totp_active, :boolean, default: false
  end
end
