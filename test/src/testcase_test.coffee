_ = require 'underscore'
sinon = require 'sinon'

Testcase = require '../../lib/testcase'

module.exports = 
  setUp: (callback) ->
    @c = new Testcase('firefox', 'safari', 'http://from', 'http://to', 'name', 'name', '/url')
    callback()

  tearDown: (callback) ->
    callback()

  'it should have correct structure': (test) ->
    test.equal @c.browser, 'firefox-safari'
    test.equal @c.from.capability, 'firefox'
    test.equal @c.from.name, 'name'
    test.equal @c.from.host, 'http://from'
    test.equal @c.to.capability, 'safari'
    test.equal @c.to.name, 'name'
    test.equal @c.to.host, 'http://to'
    test.equal @c.url, '/url'
    test.done()

  'it should get key': (test) ->
    test.equal @c.key(), 'name:/url'
    test.done()

  'it should parse correct url info when only set path': (test) ->
    [url, selector, preHandler] = Testcase.parseUrl '/'
    test.equals url, '/'
    test.equals selector, undefined
    test.equals preHandler, undefined
    test.done()

  'it should parse correct url info when only set path and pre-handler': (test) ->
    pre = ->
    [url, selector, preHandler] = Testcase.parseUrl ['/', pre]
    test.equals url, '/'
    test.equals selector, undefined
    test.equals preHandler, pre
    test.done()

  'it should parse correct url info when set path, selector and pre-handler': (test) ->
    pre = ->
    [url, selector, preHandler] = Testcase.parseUrl ['/', '#id', pre]
    test.equals url, '/'
    test.equals selector, '#id'
    test.equals preHandler, pre
    test.done()

  'it should parse correct urlinfo when set description and path': (test) ->
    [url, selector, preHandler, description] = Testcase.parseUrl { 'this is description of testcase' : '/' }
    test.equals description, 'this is description of testcase'
    test.equals url, '/'
    test.done()
  
  'it should return correct path url for testcase when set description and selector': (test) ->
    [url, selector, preHandler, description] = Testcase.parseUrl { 'this is description of testcase' : ['/', '#selector'] }
    test.equals description, 'this is description of testcase'
    test.equals url, '/'
    test.equals selector, '#selector'
    test.done()

  'it should return correct path key for testcase when set description' : (test) ->
    test.equals 'this is testcase description', Testcase.getPathKey { 'this is testcase description' : '/' }
    test.done()