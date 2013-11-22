Cx.Message = DS.Model.extend
  name: DS.attr('string')
  body: DS.attr('string')
  system: DS.attr('boolean')
  created_at: DS.attr('date')
  updated_at: DS.attr('date')
  time: (-> @get('created_at')?.toISOString()).property('created_at')

Cx.Message.FIXTURES = [
  {
    id: 1
    name: 'erundook'
    body: 'testing'
    created_at: new Date()
  }
]
