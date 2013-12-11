class OldChartItem
  include Mongoid::Document
  store_in collection: "graph_data"

  field :pairId, type: String
  field :time, type: Integer
  field :o, type: Integer
  field :h, type: Integer
  field :l, type: Integer
  field :c, type: Integer
  field :v, type: Integer

  def self.migrate
    OldChartItem.all.each do |ci|
      ChartItem.create({
        time: Time.at(ci.time/1000),
        o: ci.o,
        h: ci.h,
        l: ci.l,
        c: ci.c,
        v: ci.v,
        trade_pair: TradePair.find_by_old_id(ci.pairId)
      })
    end
  end
end
