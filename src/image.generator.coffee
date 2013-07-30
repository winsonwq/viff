path = require 'path'
_ = require 'underscore'
mr = require 'Mr.Async'
fs = require 'fs'
wrench = require 'wrench'

preprocessFolderName = (name) ->
  encodeURIComponent name

class ImageGenerator

  @generate: (reportObj) -> 
    throw new Error('compares cannot be null.') if reportObj is null

    reportObj = _.clone reportObj
    compares = reportObj.compares
    screenshotPath = path.join __dirname, '../screenshots'
    reportObjPath = path.join __dirname, '../report.json'

    wrench.rmdirSyncRecursive screenshotPath if fs.existsSync screenshotPath
    fs.unlinkSync reportObjPath if fs.existsSync reportObjPath
    wrench.mkdirSyncRecursive screenshotPath

    _.each compares, (urls, browser) ->
      browserFolderPath = path.join screenshotPath, browser
      fs.mkdirSync browserFolderPath

      _.each urls, (properties, url) ->
        urlFolderPath = path.join browserFolderPath, preprocessFolderName(url)
        fs.mkdirSync urlFolderPath

        _.each properties.images, (base64Img, env) ->
          imagePath = path.join(urlFolderPath, env + '.png')
          fs.writeFileSync imagePath, new Buffer(base64Img, 'base64')
          properties.images[env] = path.relative path.dirname(__dirname), imagePath

    fs.writeFileSync reportObjPath, JSON.stringify reportObj

module.exports = ImageGenerator