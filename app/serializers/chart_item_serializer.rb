class ChartItemSerializer < ActiveModel::Serializer
  attributes :id, :o, :h, :l, :c, :v, :trade_pair_id

  def id
    object.time.to_i * 1000
  end

  def n2f(n)
    n.to_f / 10 ** 8
  end

  def o
    n2f object.o
  end

  def h
    n2f object.h
  end

  def l
    n2f object.l
  end

  def c
    n2f object.c
  end

  def v
    n2f object.v
  end
end
