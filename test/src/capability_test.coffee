_ = require 'underscore'
sinon = require 'sinon'

Capability = require '../../lib/capability'

module.exports = 
  setUp: (callback) ->
    callback()

  tearDown: (callback) ->
    callback()

  'it should have correct structure when just set browserName': (test) ->
    capability = new Capability 'firefox'
    test.equal capability.browserName, 'firefox'
    test.done()