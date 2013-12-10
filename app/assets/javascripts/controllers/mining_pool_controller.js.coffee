Cx.MiningPoolController = Em.Controller.extend
  needs: ['blocks', 'hashrates']
  blocks: Em.computed.alias('controllers.blocks')
  hashrates: Em.computed.alias('controllers.hashrates')
