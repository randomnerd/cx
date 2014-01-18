class AddAlgoToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :algo, :string
    add_index :blocks, :algo
    Currency.find_each do |currency|
      currency.blocks.update_all algo: currency.algo
    end
  end
end
