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
    test.equal capability.key(), 'firefox'
    test.done()

  'it should have correct structure when set browserstack destop capability object': (test) ->
    cap = 
      'browser' : 'Chrome'
      'browser_version' : '31.0'
      'os' : 'OS X'
      'os_version' : 'Mavericks'

    capability = new Capability cap
    test.equal capability.key(), 'OS X - Mavericks - Chrome - 31.0'
    test.done()

  'it should have correct structure when set browserstack mobile capability object': (test) ->
    cap = 
      'platform' : 'MAC'
      'browserName' : 'iPhone'
      'device' : 'iPhone 5'

    capability = new Capability cap
    test.equal capability.key(), 'MAC - iPhone 5 - iPhone'
    test.done()