Comparison = require '../../lib/comparison.js'
sinon = require 'sinon'
_ = require 'underscore'
fs = require 'fs'

child_process = require('child_process')

module.exports = 
  setUp: (callback) ->
    @imgWithEnvs = 
      build: 'abcd'
      prod: 'efgh'

    @diffObj = 
      getImageDataUrl: () ->
        'ABCD'

    @comparison = new Comparison @imgWithEnvs

    sinon.stub(Comparison, 'compare').callsArgWith 2, @diffObj

    callback()
  tearDown: (callback) ->
    method.restore() for method in [
      Comparison.compare
    ]

    callback()

  'it should have correct properties': (test) ->
    test.equals @comparison.build, 'abcd'
    test.equals @comparison.prod, 'efgh'
    
    test.done()

  'it should find diff when build and prod': (test) ->
    callback = sinon.spy()
    @comparison.diff callback

    test.ok callback.calledOnce
    test.equals @comparison.DIFF, 'ABCD'
    test.done()

