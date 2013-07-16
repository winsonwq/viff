path = require 'path'
_ = require 'underscore'
mr = require 'Mr.Async'
spawn = require('child_process').spawn
fs = require('fs')

runDiffPath = path.join __dirname, '../bin/run_viff.sh'

viffDir = path.join path.dirname(__dirname), 'tmp'
fs.mkdirSync viffDir unless fs.existsSync viffDir

newFileName = -> new Date().getTime() + (Math.random(1) * Math.random(1)).toFixed(2) * 100 + '.png'

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

    Comparison.convertAndCompare filePaths[0], filePaths[1], (diffPath) -> 
      if diffPath
        fullFilePaths = Comparison.convertToFullFilePaths _.union filePaths, [diffPath]
        
        that.reloadFromPaths fullFilePaths
        defer.resolve that.DIFF
        Comparison.clearFiles fullFilePaths

    defer.promise()

  reloadFromPaths: (filePaths) ->
    envs = _.keys @
    envs.push 'DIFF'

    for env, idx in envs
      @[env] = fs.readFileSync(filePaths[idx], 'base64')

  @convertToFullFilePaths: (filePaths) ->
    fp.replace('.png', '.jpg') for fp in filePaths

  @clearFiles: (filePaths) ->
    fs.unlinkSync fp for fp in filePaths

  @convertAndCompare: (filePathA, filePathB, callback) ->
    defer = mr.Deferred()
    defer.done callback

    outputFilePath = path.join viffDir, newFileName()
    runDiff = spawn runDiffPath, [filePathA, filePathB, outputFilePath]

    runDiff.stdout.on 'data', (data) -> 
      console.log 'stdout: ' + data

    runDiff.stderr.on 'data', (data) -> 
      console.log 'stderr: ' + data

    runDiff.on 'close', (code) ->
      if code == 0
        defer.resolve outputFilePath
      else
        defer.reject()

    defer.promise()

module.exports = Comparison