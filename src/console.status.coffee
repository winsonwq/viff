require './color.helper.js'
Viff = require './viff.js'

module.exports = (viff) ->
  currentBrowserName = null
  currentUrl = null
  currentCaseName = null
  caseDuration = 0

  console.log 'Viff is taking screenshots...'
  viff.on 'tookScreenshot', (browserName, envHost, url, druation, base64Img) ->
    if currentBrowserName isnt browserName
      currentBrowserName = browserName
      console.log "#{currentBrowserName.info}"

    caseName = Viff.getPathKey url
    caseDuration += druation

    if currentCaseName isnt caseName
      console.log "  #{Viff.getPathKey url} (#{caseDuration}ms)"
      currentCaseName = caseName
      caseDuration = 0