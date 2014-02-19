'use strict';

vm = require 'vm'
Path = require 'path'

module.exports = (content) ->
  exports = {}
  sandbox =
    require: require
    exports: exports
    module: 
      exports: exports
    global: sandbox

  if Buffer.isBuffer(content)
    content = content.toString()
  
  if typeof content == 'string'
    vm.createScript( content.replace(/^\#\!.*/, ''))
      .runInNewContext(sandbox)
  else
    content.runInNewContext(sandbox)

  sandbox.module.exports