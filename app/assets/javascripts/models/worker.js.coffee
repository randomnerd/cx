Cx.Worker = DS.Model.extend
  name: DS.attr('string')
  pass: DS.attr('string')
  created_at: DS.attr('date')
  updated_at: DS.attr('date')
  stats: (->
    @store.filter 'workerStat', (o) =>
      o.get('worker_id') == parseInt(@get('id')) &&
      +new Date(o.get('updated_at')) > +new Date() - 2 * 60 * 1000
  ).property()
