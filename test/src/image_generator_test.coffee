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
          "build": "base64_build_1"
          "prod": "base64_prod_1"
          "DIFF": "base64_diff_1"
        "/":
          "build": "base64_build_2"
          "prod": "base64_prod_2"
          "DIFF": "base64_diff_2"
      "chrome": 
        "/404.html": 
          "build": "base64_build_3"
          "prod": "base64_prod_3"
          "DIFF": "base64_diff_3"
        "/":
          "build": "base64_build_4"
          "prod": "base64_prod_4"
          "DIFF": "base64_diff_4"

    @mkdirSync = sinon.stub(fs, 'mkdirSync').returns 1
    @existsSync = sinon.stub(fs, 'existsSync').returns true
    @writeFileSync = sinon.stub(fs, 'writeFileSync').returns undefined
    @rmdirSyncRecursive = sinon.stub(wrench, 'rmdirSyncRecursive').returns undefined
    @mkdirSyncRecursive = sinon.stub(wrench, 'mkdirSyncRecursive').returns undefined

    callback()

  tearDown: (callback) ->
    method.restore() for method in [
      fs.mkdirSync
      fs.existsSync
      fs.writeFileSync
      wrench.rmdirSyncRecursive
      wrench.mkdirSyncRecursive
    ]
    callback()

  'it should remove "screenshots" folder if exist': (test) ->
    ImageGenerator.generate @compares
    test.ok @rmdirSyncRecursive.lastCall.args[0].indexOf('/screenshots') >= 0

    test.done()

  'it should generate correct directories': (test) ->
    ImageGenerator.generate @compares
    test.equals @mkdirSync.callCount, 6
    test.ok @mkdirSync.getCall(1).args[0].indexOf('/screenshots/firefox/%2F404.html%3Fa%3D1') >= 0
    test.ok @mkdirSync.getCall(3).args[0].indexOf('/screenshots/chrome') >= 0
    test.done()    

  'it should always create new "screenshots" folder': (test) ->
    ImageGenerator.generate @compares
    test.ok @mkdirSyncRecursive.lastCall.args[0].indexOf('/screenshots') >= 0
    test.done()

  'it should generate correct images': (test) ->
    ImageGenerator.generate @compares
    test.equals @writeFileSync.callCount, 12
    test.done()

