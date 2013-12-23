_ = require 'underscore'
sinon = require 'sinon'
path = require 'path'
fs = require 'fs'
wrench = require 'wrench'

ImageGenerator = require '../../lib/image.generator.js'

module.exports = 
  setUp: (callback) ->

    @mkdirSync = sinon.stub(fs, 'mkdirSync').returns 1
    @existsSync = sinon.stub(fs, 'existsSync').returns true
    @writeFileSync = sinon.stub(fs, 'writeFileSync').returns undefined
    @unlinkSync = sinon.stub(fs, 'unlinkSync').returns undefined
    @rmdirSyncRecursive = sinon.stub(wrench, 'rmdirSyncRecursive').returns undefined
    @mkdirSyncRecursive = sinon.stub(wrench, 'mkdirSyncRecursive').returns undefined

    callback()

  tearDown: (callback) ->
    method.restore() for method in [
      fs.mkdirSync
      fs.existsSync
      fs.writeFileSync
      fs.unlinkSync
      wrench.rmdirSyncRecursive
      wrench.mkdirSyncRecursive
    ]
    callback()

  'it could generate images by case': (test) ->
    c = 
      browser: 'firefox'
      url: '/link1'
      fromname: 'build'
      toname: 'prod'
      from: { 'build': 'http://localhost:4000' }
      to: { 'prod': 'http://localhost:4001' }
      result:
        images:
          build: 'ABCD'
          prod: 'EFGH'
          diff: 'IJKL'
        isSameDimensions: true
        misMatchPercentage: 0.2
        analysisTime: 2000
    
    @existsSync = @existsSync.returns false

    ImageGenerator.generateByCase c

    test.ok @mkdirSync.firstCall.args[0].indexOf('/viff/screenshots/firefox') >= 0
    test.ok @mkdirSync.secondCall.args[0].indexOf('/viff/screenshots/firefox/%2Flink1') >= 0
    test.equals @writeFileSync.callCount, 3
    test.ok @writeFileSync.firstCall.args[0].indexOf('/viff/screenshots/firefox/%2Flink1/build.png') >= 0
    test.done()

