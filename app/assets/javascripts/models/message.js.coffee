Cx.Message = DS.Model.extend
  name: DS.attr('string')
  body: DS.attr('string')
  created_at: DS.attr('date')

Cx.Message.FIXTURES = [
  {
    id: 1
    name: 'erundook'
    body: 'testing'
    created_at: new Date()
  }
]
