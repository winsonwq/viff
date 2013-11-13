require './color.helper.js'
Viff = require './viff.js'

module.exports = (viff) ->
  currentBrowserName = null
  currentUrl = null
  currentCaseName = null
  caseDuration = 0

  console.log 'Viff is taking screenshots...'
  viff.on 'afterEach', (c, duration) ->
    if currentBrowserName isnt c.browser
      currentBrowserName = c.browser
      console.log "#{currentBrowserName.info}"

    caseName = Viff.getPathKey c.url
    caseDuration += duration

    if currentCaseName isnt caseName
      console.log "#{Viff.getPathKey c.url} (#{duration}ms)"
      currentCaseName = caseName
      caseDuration = 0