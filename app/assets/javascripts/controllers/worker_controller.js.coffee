Cx.WorkerController = Em.ObjectController.extend
  pwFieldType: 'password'
  showingPassword: false
  allowSave: (->
    return false unless @get('name') && @get('pass')
    return false if @get('id') && !@get('isDirty')
    true
  ).property('isDirty', 'name', 'pass', 'id')
  actions:
    save: (worker) ->
      onErr = (data) => @set 'nameError', true if data.errors.name
      onOk  = (data) => @set 'nameError', false
      worker.save().then(onOk, onErr)
    remove: (worker) ->
      worker.deleteRecord()
      worker.save() if worker.get('id')
    toggleShowPass: ->
      show = !@get 'showingPassword'
      type = if show then 'text' else 'password'
      @set 'pwFieldType', type
      @set 'showingPassword', show
