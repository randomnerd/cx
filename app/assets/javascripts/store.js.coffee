# http://emberjs.com/guides/models/using-the-store/

Cx.ApplicationSerializer = DS.ActiveModelSerializer
Cx.ApplicationAdapter = DS.ActiveModelAdapter.reopen
  namespace: 'api/v1'
