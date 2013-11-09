# http://emberjs.com/guides/models/using-the-store/

# Cx.ApplicationAdapter = DS.FixtureAdapter.extend
#   queryFixtures: (models, query, klass) ->
#     ret = []
#     for m in models
#       match = true
#       for key, value of query
#         if typeof(m[key]) == 'number' then value = parseFloat(value)
#         match = false unless m[key] == value
#       ret.push m if match
#     ret
#     # if ret.length > 1 then ret else new klass(ret[0])

DS.ActiveModelAdapter.reopen
  namespace: 'api/v1'

Cx.Store = DS.Store.extend
  # Override the default adapter with the `DS.ActiveModelAdapter` which
  # is built to work nicely with the ActiveModel::Serializers gem.
  adapter: '_ams'
