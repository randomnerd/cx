class AddSkipSwitchToCurrencies < ActiveRecord::Migration
  def change
    add_column :currencies, :mining_skip_switch, :boolean, default: false
  end
end
