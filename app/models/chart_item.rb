class ChartItem < ActiveRecord::Base
  belongs_to :trade_pair

  def self.lighting(tpid)
    connection.select_all(where(trade_pair_id: tpid).select([:time, :o, :h, :l, :c, :v]).arel).map do |attrs|
      [
        DateTime.parse(attrs['time']).to_i,
        attrs['o'].to_i,
        attrs['h'].to_i,
        attrs['l'].to_i,
        attrs['c'].to_i,
        attrs['v'].to_i
      ]
    end
  end

  def self.fill(tpid)
    chain = Trade.where(trade_pair_id: tpid)
    chain = chain.select("from_unixtime(floor(unix_timestamp(trades.created_at)/(#{group_interval}*60))*(#{group_interval}*60)) as time")
    chain = chain.select("min(id) as min_id")
    chain = chain.select("max(id) as max_id")
    chain = chain.select("max(trades.rate) as h")
    chain = chain.select("min(trades.rate) as l")
    chain = chain.select("sum(trades.amount) as v")
    chain = chain.group("time")
    items = chain.each do |item|
      self.create(
        time: item.time,
        o:  Trade.find(item.min_id).try(:rate),
        h:  item.h,
        l:  item.l,
        c:  Trade.find(item.max_id).try(:rate),
        v:  item.v,
        trade_pair_id: tpid
      )
    end
  end

  def self.group_interval
    30
  end
end
