_ = require 'underscore'
sinon = require 'sinon'
path = require 'path'
fs = require 'fs'
wrench = require 'wrench'

ImageGenerator = require '../../lib/image.generator.js'

module.exports = 
  setUp: (callback) ->
    @compares = 
      "firefox": 
        "/404.html?a=1": 
          isSameDimensions: true
          misMatchPercentage: 3
          analysisTime: 51
          images:
            "build": "base64_build_1"
            "prod": "base64_prod_1"
            "diff": "base64_diff_1"
        "/":
          isSameDimensions: true
          misMatchPercentage: 3
          analysisTime: 52
          images:
            "build": "base64_build_2"
            "prod": "base64_prod_2"
            "diff": "base64_diff_2"
      "chrome": 
        "/404.html": 
          isSameDimensions: true
          misMatchPercentage: 11
          analysisTime: 53
          images:
            "build": "base64_build_3"
            "prod": "base64_prod_3"
            "diff": "base64_diff_3"
        "/":
          isSameDimensions: true
          misMatchPercentage: 0
          analysisTime: 54
          images:
            "build": "base64_build_4"
            "prod": "base64_prod_4"
            "DIFF": "base64_diff_4"

    @reporterObj = 
      compares: @compares
      caseCount: 3
      sameCount: 2
      diffCount: 1
      totalAnalysisTime: 210

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

  'it should remove "screenshots" folder if exist': (test) ->
    ImageGenerator.generate @reporterObj
    test.ok @rmdirSyncRecursive.lastCall.args[0].indexOf('/screenshots') >= 0

    test.done()

  'it should remove report.json file if exist': (test) ->
    ImageGenerator.generate @reporterObj
    test.ok @unlinkSync.lastCall.args[0].indexOf('/report.json') >= 0

    test.done()

  'it should generate correct directories': (test) ->
    ImageGenerator.generate @reporterObj
    test.equals @mkdirSync.callCount, 6
    test.ok @mkdirSync.getCall(1).args[0].indexOf('/screenshots/firefox/%2F404.html%3Fa%3D1') >= 0
    test.ok @mkdirSync.getCall(3).args[0].indexOf('/screenshots/chrome') >= 0
    test.done()    

  'it should always create new "screenshots" folder': (test) ->
    ImageGenerator.generate @reporterObj
    test.ok @mkdirSyncRecursive.lastCall.args[0].indexOf('/screenshots') >= 0
    test.done()

  'it should always create new report.json file': (test) ->
    ImageGenerator.generate @reporterObj
    test.ok @writeFileSync.lastCall.args[0].indexOf('/report.json') >= 0
    test.done()

  'it should generate correct images': (test) ->
    ImageGenerator.generate @reporterObj
    test.equals @writeFileSync.callCount, 13
    test.done()

  'it should generate file-based json file': (test) ->
    ImageGenerator.generate @reporterObj
    parsedCompares = JSON.parse @writeFileSync.lastCall.args[1]
    test.equals parsedCompares.compares.firefox['/404.html?a=1'].images.build, 'screenshots/firefox/%2F404.html%3Fa%3D1/build.png'

    test.done()

