path = require 'path'
_ = require 'underscore'
mr = require 'Mr.Async'
spawn = require('child_process').spawn
fs = require('fs')
resemble = require('resemble').resemble

newFileName = -> new Date().getTime() + (Math.random(1) * Math.random(1)).toFixed(2) * 100 + '.png'

class Comparison
  constructor: (imgWithEnvs) ->
    _.extend(@, imgWithEnvs)

  diff: (callback) ->
    defer = mr.Deferred()
    defer.done callback

    that = @
    fileData = _.map _.values(@), (base64Img) ->
      new Buffer base64Img, 'base64'

    Comparison.compare fileData[0], fileData[1], (diffObj) -> 
      if diffObj
        that.DIFF = diffObj.getImageDataUrl().replace('data:image/png;base64,', '')
        defer.resolve that.DIFF

    defer.promise()

  @compare: (fileAData, fileBData, callback) ->
    defer = mr.Deferred()
    defer.done callback

    resemble(fileAData).compareTo(fileBData).onComplete (data) ->
      defer.resolve data

    defer.promise()

module.exports = Comparison