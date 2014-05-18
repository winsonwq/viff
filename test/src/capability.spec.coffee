_ = require 'underscore'
sinon = require 'sinon'

Capability = require '../../lib/capability'

describe 'capability', ->

  it 'should have correct structure when just set browserName', () ->
    capability = new Capability 'firefox'
    capability.browserName.should.equal 'firefox'
    capability.key().should.equal 'firefox'

  it 'should have correct structure when set browserstack destop capability object', () ->
    cap =
      'browser': 'Chrome'
      'browser_version' : '31.0'
      'os' : 'OS X'
      'os_version' : 'Mavericks'

    capability = new Capability cap
    capability.key().should.equal 'OS X - Mavericks - Chrome - 31.0'

  it 'should have correct structure when set browserstack mobile capability object', () ->
    cap =
      'platform' : 'MAC'
      'browserName' : 'iPhone'
      'device' : 'iPhone 5'

    capability = new Capability cap
    capability.key().should.equal 'MAC - iPhone 5 - iPhone'

  it 'should construct by Capability object as well', () ->
    capability = new Capability(new Capability('firefox'))
    capability.browserName.should.equal 'firefox'
    capability.key().should.equal 'firefox'
