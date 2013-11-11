Cx.ChartItem = DS.Model.extend
  o: DS.attr('number')
  h: DS.attr('number')
  l: DS.attr('number')
  c: DS.attr('number')
  v: DS.attr('number')
  tradePair: DS.belongsTo('tradePair')
