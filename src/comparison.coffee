path = require 'path'
_ = require 'underscore'
Q = require 'q'
fs = require('fs')

resemble = require './resemble'

class Comparison
  constructor: (imgWithEnvs) ->
    @images = imgWithEnvs

  diff: (callback) ->
    defer = Q.defer()
    promise = defer.promise.then callback

    that = @
    fileData = _.values(@images)

    Comparison.compare fileData[0], fileData[1], (diffObj) ->

      if diffObj
        diffBase64 = diffObj.imageDataUrl.replace('data:image/png;base64,', '')
        that.images.diff = new Buffer diffBase64, 'base64'

        _.extend that,
          isSameDimensions: diffObj.isSameDimensions
          misMatchPercentage: Number diffObj.misMatchPercentage
          analysisTime: diffObj.analysisTime

        defer.resolve that.images.diff

    promise

  @compare: (fileAData, fileBData, callback) ->
    defer = Q.defer()
    promise = defer.promise.then callback
    resemble.compare Comparison.base64fy(fileAData), Comparison.base64fy(fileBData), (data) ->
      defer.resolve data

    promise

  @base64fy: (imageBuffer) ->
    "data:image/png;base64,#{imageBuffer.toString('base64')}"

module.exports = Comparison
