_ = require 'underscore'
sinon = require 'sinon'

Case = require '../../lib/case.js'

module.exports = 
  setUp: (callback) ->
    callback()

  tearDown: (callback) ->
    callback()

  'it should have correct structure': (test) ->
    c = new Case('firefox-safari', 'firefox', 'safari', 'http://from', 'http://to', 'nameFrom', 'nameTo', '/url')
    test.equal c.browser, 'firefox-safari'
    test.equal c.from.browser, 'firefox'
    test.equal c.from.name, 'nameFrom'
    test.equal c.from.host, 'http://from'
    test.equal c.to.browser, 'safari'
    test.equal c.to.name, 'nameTo'
    test.equal c.to.host, 'http://to'
    test.equal c.url, '/url'
    test.done()