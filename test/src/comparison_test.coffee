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
      isSameDimensions: true
      misMatchPercentage: "2.84"
      analysisTime: 54
      getImageDataUrl: () -> 'ABCD'

    @comparison = new Comparison @imgWithEnvs

    sinon.stub(Comparison, 'compare').callsArgWith 2, @diffObj

    callback()
  tearDown: (callback) ->
    method.restore() for method in [
      Comparison.compare
    ]

    callback()

  'it should have correct properties': (test) ->
    test.equals @comparison.images.build, 'abcd'
    test.equals @comparison.images.prod, 'efgh'
    
    test.done()

  'it should find diff when build and prod': (test) ->
    callback = sinon.spy()
    @comparison.diff callback

    test.ok callback.calledOnce
    test.equals @comparison.images.diff.toString('base64'), 'ABCD'
    test.done()

  'it should get correct diff property': (test) ->
    @comparison.diff =>
      test.ok @comparison.isSameDimensions
      test.strictEqual @comparison.misMatchPercentage, 2.84
      test.equals @comparison.analysisTime, 54
      test.done()

