path = require 'path'
_ = require 'underscore'
mr = require 'Mr.Async'
fs = require 'fs'
wrench = require 'wrench'

preprocessFolderName = (name) ->
  encodeURIComponent name

class ImageGenerator

  @generate: (compares) -> 
    throw new Error('compares cannot be null.') if compares is null

    screenshotPath = path.join(__dirname, '../screenshots')
    wrench.rmdirSyncRecursive(screenshotPath) if fs.existsSync screenshotPath
    wrench.mkdirSyncRecursive screenshotPath

    for browser, urls of compares
      browserFolderPath = path.join screenshotPath, browser
      fs.mkdirSync browserFolderPath

      for url, images of urls
        urlFolderPath = path.join browserFolderPath, preprocessFolderName(url)
        fs.mkdirSync urlFolderPath

        _.each images, (base64Img, image) ->
          fs.writeFileSync path.join(urlFolderPath, image + '.png'), new Buffer(base64Img, 'base64')

module.exports = ImageGenerator