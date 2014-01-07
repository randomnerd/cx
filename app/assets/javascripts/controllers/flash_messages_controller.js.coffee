Cx.CommonFlashMessagesController = Em.ObjectController.extend
  alerts: Em.ArrayProxy.create(content: [])
  notices: Em.ArrayProxy.create(content: [])

  add_alert: (msg) -> @get('alerts').addObject msg
  add_notice: (msg) -> @get('notices').addObject msg
