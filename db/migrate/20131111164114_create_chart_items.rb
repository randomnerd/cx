class CreateChartItems < ActiveRecord::Migration
  def change
    create_table :chart_items do |t|
      t.datetime :time
      t.integer  :o, limit: 8, default: 0
      t.integer  :h, limit: 8, default: 0
      t.integer  :l, limit: 8, default: 0
      t.integer  :c, limit: 8, default: 0
      t.integer  :v, limit: 8, default: 0
      t.integer  :trade_pair_id
    end
    add_index :chart_items, [:trade_pair_id, :time]
  end
end
