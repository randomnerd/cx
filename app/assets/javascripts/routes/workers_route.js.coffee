Cx.WorkersRoute = Cx.AuthRoute.extend
  model: -> @store.findAll 'worker'
  setupController: (c, m) -> c.set 'model', m
