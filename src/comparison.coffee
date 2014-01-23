path = require 'path'
_ = require 'underscore'
mr = require 'Mr.Async'
fs = require('fs')
{resemble} = require 'resemble'

class Comparison
  constructor: (imgWithEnvs) ->
    @images = imgWithEnvs

  diff: (callback) ->
    defer = mr.Deferred().done callback

    that = @
    fileData = _.values(@images)

    Comparison.compare fileData[0], fileData[1], (diffObj) -> 
      if diffObj
        diffBase64 = diffObj.getImageDataUrl().replace('data:image/png;base64,', '')
        that.images.diff = new Buffer diffBase64, 'base64'

        _.extend that, 
          isSameDimensions: diffObj.isSameDimensions
          misMatchPercentage: Number diffObj.misMatchPercentage    
          analysisTime: diffObj.analysisTime

        defer.resolve that.images.diff

    defer.promise()

  @compare: (fileAData, fileBData, callback) ->
    defer = mr.Deferred().done callback

    resemble(fileAData).compareTo(fileBData).onComplete (data) ->
      defer.resolve data

    defer.promise()

module.exports = Comparison