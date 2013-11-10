Cx.Message = DS.Model.extend
  name: DS.attr('string')
  body: DS.attr('string')
  createdAt: DS.attr('date')
  time: (-> @get('createdAt')?.toISOString()).property('createdAt')

Cx.Message.FIXTURES = [
  {
    id: 1
    name: 'erundook'
    body: 'testing'
    created_at: new Date()
  }
]
