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

    @comparison = new Comparison @imgWithEnvs

    sinon.stub(Comparison, 'findDiff').callsArgWith 2, '/diffPath'
    sinon.stub(fs, 'readFileSync').withArgs('/diffPath', 'base64').returns('diffBase64String')
    sinon.stub(fs, 'unlinkSync').returns undefined
    sinon.stub(fs, 'writeFileSync').returns undefined

    callback()
  tearDown: (callback) ->
    method.restore() for method in [
      Comparison.findDiff
      fs.readFileSync 
      fs.unlinkSync
      fs.writeFileSync
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
    test.equals @comparison.DIFF, 'diffBase64String'
    test.done()

