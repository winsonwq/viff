path = require 'path'
_ = require 'underscore'
mr = require 'Mr.Async'
fs = require 'fs'
wrench = require 'wrench'
EventEmitter = require('events').EventEmitter

preprocessFolderName = (name) ->
  encodeURIComponent name

currentRunningDirname = process.cwd()

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

  createImageFile: (imagePath, base64Img) ->
    fs.writeFileSync imagePath, new Buffer(base64Img, 'base64')
    ImageGenerator.emit ImageGenerator.CREATE_FILE, imagePath      

  createFolder: (folderPath) ->
    fs.mkdirSync folderPath
    ImageGenerator.emit ImageGenerator.CREATE_FOLDER, folderPath        

  generateFoldersAndImages: (basePath, compares) ->
    # would modify the compares object
    _.each compares, (urls, browser) ->
      browserFolderPath = path.join basePath, browser
      ImageGenerator.createFolder browserFolderPath

      _.each urls, (properties, url) ->
        urlFolderPath = path.join browserFolderPath, preprocessFolderName(url)
        ImageGenerator.createFolder urlFolderPath

        _.each properties.images, (base64Img, env) ->
          imagePath = path.join(urlFolderPath, env + '.png')
          ImageGenerator.createImageFile imagePath, base64Img
          properties.images[env] = path.relative currentRunningDirname, imagePath

  generateReportJsonFile: (reportJsonPath, reportObj) ->
    fs.writeFileSync reportJsonPath, JSON.stringify reportObj
    ImageGenerator.emit ImageGenerator.CREATE_FILE, reportJsonPath

  generate: (reportObj) -> 
    throw new Error('compares cannot be null.') if reportObj is null

    reportObj = _.clone reportObj
    screenshotPath = path.join currentRunningDirname, './screenshots'
    reportJsonPath = path.join currentRunningDirname, './report.json'

    ImageGenerator.resetFolderAndFile screenshotPath, reportJsonPath
    ImageGenerator.generateFoldersAndImages screenshotPath, reportObj.compares
    ImageGenerator.generateReportJsonFile reportJsonPath, reportObj

module.exports = ImageGenerator