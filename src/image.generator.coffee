path = require 'path'
_ = require 'underscore'
wrench = require 'wrench'
{EventEmitter} = require 'events'
es = require 'event-stream'
Promise = require 'bluebird'
resumer = require 'resumer'
mkdirp = require 'mkdirp'
fs = require 'fs'
vfs = require 'vinyl-fs'

helper = require './image.dataurl.helper'
Viff = require './viff'

preprocessFolderName = (_case) -> encodeURIComponent _case.key()
getScreenshotPath = (_case) ->
  path.join _case.reportPath, 'screenshots'
getreportJsonPath = (_case) ->
  path.join getScreenshotPath(_case), 'report.json'
getEnv = (_case, index) ->
  keys = for key, img of _case.result.images
        key
  keys[index]
currentRunningDirname = process.cwd()
screenshotPath = path.join currentRunningDirname, './screenshots'
reportJsonPath = path.join currentRunningDirname, './report.json'

events = 
  CREATE_FOLDER: 'createFolder'
  CREATE_FILE: 'createFile'

ImageGenerator = Object.create EventEmitter.prototype

_.extend ImageGenerator, events
_.extend ImageGenerator, 
  # resetFolderAndFile: (screenshotPath, reportObjPath) ->
  #   wrench.rmdirSyncRecursive screenshotPath if fs.existsSync screenshotPath
  #   fs.unlinkSync reportObjPath if fs.existsSync reportObjPath
    
  #   wrench.mkdirSyncRecursive screenshotPath
  #   ImageGenerator.emit ImageGenerator.CREATE_FOLDER, screenshotPath

  createImageFile: (imagePath, img, cb) ->
    imagefile = fs.createWriteStream(imagePath,{
      flags: 'w',
      encoding: 'base64',
      mode: '0666'
    })
    ImageGenerator
      .stringToStream img
      .on 'end', () ->
        ImageGenerator.emit ImageGenerator.CREATE_FILE, imagePath
        cb && cb()
      .pipe(imagefile)

  # createFolder: (folderPath) ->
  #   unless fs.existsSync folderPath
  #     fs.mkdirSync folderPath
  #     ImageGenerator.emit ImageGenerator.CREATE_FOLDER, folderPath        

  generateReportJsonFile: (reportJsonPath, reportObj, cb) ->
    jsonfile = fs.createWriteStream(reportJsonPath,{
      flags: 'w',
      encoding: 'utf8',
      mode: '0666'
    })
    ImageGenerator
      .stringToStream(JSON.stringify(reportObj))
      # .on 'data', (data) ->
        # console.log
      .on 'end', () ->
        ImageGenerator.emit ImageGenerator.CREATE_FILE, reportJsonPath
        cb && cb()
      .pipe(jsonfile)

  # reset: -> ImageGenerator.resetFolderAndFile screenshotPath, reportJsonPath

  generateByCase: (_case) ->
    new Promise (resolve, reject) ->
      browserFolderPath = path.join screenshotPath, _case.browser
      urlFolderPath = path.join browserFolderPath, preprocessFolderName(_case)
      imgs = for key, img of _case.result.images
        img
      Promise
        .map imgs, (img, index) ->
          env = getEnv _case, index
          new Promise (res, rej) ->
            imagePath = path.join(urlFolderPath, env + '.png')
            mkdirp urlFolderPath, (err) ->
              if err
                rej()
              ImageGenerator.createImageFile imagePath, img, () ->
                  _case.result.images[env] = path.relative currentRunningDirname, imagePath
                  res()
        .then (imgs) ->
          resolve _case
        .catch SyntaxError, (e) ->
          reject("Invalid JSON in file " + e.fileName + ": " + e.message);

  generateFailedCase: (_case) ->
    new Promise (resolve, reject) ->
      browserFolderPath = path.join screenshotPath, _case.browser
      urlFolderPath = path.join browserFolderPath, preprocessFolderName(_case)
      if _case.result
        imgs = (img for img of _case.result.images)
        Promise
          .map imgs, (img, index) ->
            env = getEnv _case, index
            new Promise (res, rej) ->
              imagePath = path.join(urlFolderPath, env + '.png')
              mkdirp urlFolderPath, (err) ->
                if err
                  rej()
                ImageGenerator.createImageFile imagePath, img, () ->
                    _case.result.images[env] = path.relative currentRunningDirname, imagePath
                    res()
          .then (imgs) ->
            resolve _case
          .catch SyntaxError, (e) ->
            reject("Invalid JSON in file " + e.fileName + ": " + e.message);
      else
        resolve _case
  generateReport: (cases) ->
    compares = {}
    differences = []
    totalAnalysisTime = 0

    _.each cases, (_case) ->
      if _case.result
        compares[_case.browser] = compares[_case.browser] || {}
        compares[_case.browser][_case.key()] = _case.result

        differences.push _case if _case.result.misMatchPercentage isnt 0
        totalAnalysisTime += _case.result.analysisTime
      else
        differences.push _case

    reportObj = 
      compares: compares
      caseCount: cases.length
      sameCount: cases.length - differences.length
      diffCount: differences.length
      totalAnalysisTime: totalAnalysisTime 

    ImageGenerator.generateReportJsonFile reportJsonPath, reportObj

  stringToStream: (data) ->
    resumer().queue(data).end()

module.exports = ImageGenerator