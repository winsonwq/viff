path = require 'path'
_ = require 'underscore'
mr = require 'Mr.Async'
spawn = require('child_process').spawn
fs = require('fs')

viffDir = path.join path.dirname(__dirname), 'tmp'
fs.mkdirSync viffDir unless fs.existsSync viffDir

newFileName = -> new Date().getTime() + (Math.random(1) * Math.random(1) * 100).toFixed(2) + '.png'

class Comparison
  constructor: (imgWithEnvs) ->
    _.extend(@, imgWithEnvs)

  diff: (callback) ->
    defer = mr.Deferred()
    defer.done callback

    filePaths = []
    that = @

    _.each @, (base64Img, env) ->
      filePath = path.join viffDir, newFileName()
      fs.writeFileSync filePath, new Buffer(that[env], 'base64')
      filePaths.push filePath

    Comparison.findDiff filePaths[0], filePaths[1], (diffPath) -> 
      if diffPath
        _.extend that, { DIFF: fs.readFileSync(diffPath, 'base64') }
        defer.resolve that.DIFF
      fs.unlinkSync(fp) for fp in _.union filePaths, [diffPath]

    defer.promise()


  @findDiff: (filePathA, filePathB, callback) ->
    defer = mr.Deferred()
    defer.done callback

    outputFilePath = path.join viffDir, newFileName()

    runDiff = spawn 'compare', [filePathA, filePathB, outputFilePath]

    runDiff.stdout.on 'data', (data) -> 
      console.log 'stdout: ' + data

    runDiff.stderr.on 'data', (data) -> 
      console.log 'stderr: ' + data

    runDiff.on 'close', (code) ->
      if code == 0
        defer.resolve(outputFilePath)
      else
        defer.reject()

    defer.promise()

module.exports = Comparison