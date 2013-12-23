path = require 'path'
_ = require 'underscore'
mr = require 'Mr.Async'
fs = require 'fs'
wrench = require 'wrench'
{EventEmitter} = require('events')

Viff = require './viff'

preprocessFolderName = (name) ->
  encodeURIComponent Viff.getPathKey name

currentRunningDirname = process.cwd()
screenshotPath = path.join currentRunningDirname, './screenshots'
reportJsonPath = path.join currentRunningDirname, './report.json'

events = 
  CREATE_FOLDER: 'createFolder'
  CREATE_FILE: 'createFile'

ImageGenerator = Object.create EventEmitter.prototype

_.extend ImageGenerator, events
_.extend ImageGenerator, 
  resetFolderAndFile: (screenshotPath, reportObjPath) ->
    wrench.rmdirSyncRecursive screenshotPath if fs.existsSync screenshotPath
    fs.unlinkSync reportObjPath if fs.existsSync reportObjPath
    
    wrench.mkdirSyncRecursive screenshotPath
    ImageGenerator.emit ImageGenerator.CREATE_FOLDER, screenshotPath

  createImageFile: (imagePath, img) ->
    fs.writeFileSync imagePath, img
    ImageGenerator.emit ImageGenerator.CREATE_FILE, imagePath      

  createFolder: (folderPath) ->
    unless fs.existsSync folderPath
      fs.mkdirSync folderPath
      ImageGenerator.emit ImageGenerator.CREATE_FOLDER, folderPath        

  generateReportJsonFile: (reportJsonPath, reportObj) ->
    fs.writeFileSync reportJsonPath, JSON.stringify reportObj
    ImageGenerator.emit ImageGenerator.CREATE_FILE, reportJsonPath

  reset: -> ImageGenerator.resetFolderAndFile screenshotPath, reportJsonPath

  generateByCase: (_case) ->
    browserFolderPath = path.join screenshotPath, _case.browser
    urlFolderPath = path.join browserFolderPath, preprocessFolderName(_case.url)

    ImageGenerator.createFolder browserFolderPath
    ImageGenerator.createFolder urlFolderPath

    _.each _case.result.images, (img, env) ->
      imagePath = path.join(urlFolderPath, env + '.png')
      ImageGenerator.createImageFile imagePath, img
      _case.result.images[env] = path.relative currentRunningDirname, imagePath
    
  generateReport: (cases) ->
    compares = {}
    differences = []
    totalAnalysisTime = 0

    _.each cases, (_case) ->
      if _case.result
        path = Viff.getPathKey _case.url
        compares[_case.browser] = compares[_case.browser] || {}
        compares[_case.browser][path] = _case.result

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

module.exports = ImageGenerator