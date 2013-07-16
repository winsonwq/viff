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

    sinon.stub(Comparison, 'convertAndCompare').callsArgWith 2, '/diffPath'
    sinon.stub(fs, 'readFileSync').returns('base64String')
    sinon.stub(fs, 'unlinkSync').returns undefined
    sinon.stub(fs, 'writeFileSync').returns undefined

    callback()
  tearDown: (callback) ->
    method.restore() for method in [
      Comparison.convertAndCompare
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
    test.equals @comparison.DIFF, 'base64String'
    test.done()

  'it should convert to correct .jpg file paths': (test) ->
    fullFilePaths = Comparison.convertToFullFilePaths ['a.png', 'b.png', 'c.png']
    test.ok _.isEqual fullFilePaths, ['a.jpg', 'b.jpg', 'c.jpg']
    test.done()

  'it should reload from new file paths': (test) ->
    newFilesPaths = ['a.png', 'b.png', 'c.png']
    @comparison.reloadFromPaths newFilesPaths
    test.equals @comparison.build, 'base64String'
    test.equals @comparison.prod, 'base64String'
    test.equals @comparison.DIFF, 'base64String'
    test.done()

