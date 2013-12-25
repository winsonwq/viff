require './color.helper.js'
imgGen = require './image.generator.js'
Viff = require './viff'

durationFormat = (duration) -> (duration / 1000).toFixed(2) + 's'

module.exports = (viff) ->

  currentBrowserName = null
  currentUrl = null
  currentCaseName = null
  caseDuration = 0

  # clean the images and report.json
  viff.on 'before', (cases) -> console.log 'Viff is taking screenshots...'

  viff.on 'afterEach', (_case, duration) ->
    if currentBrowserName isnt _case.browser
      currentBrowserName = _case.browser
      console.log "#{currentBrowserName.info}"

    caseName = _case.key()
    caseDuration += duration

    if currentCaseName isnt caseName
      console.log "#{_case.key()} (#{durationFormat(duration)})"
      currentCaseName = caseName
      caseDuration = 0

  # generate report.json  
  viff.on 'after', (cases, duration) -> console.log "\nDone in #{durationFormat(duration)}."

  imgGen.on imgGen.CREATE_FOLDER, (folerPath) ->
    console.log "#{ 'viff'.greyColor } #{ 'create'.info } #{ 'folder'.prompt } #{folerPath}"

  imgGen.on imgGen.CREATE_FILE, (filePath) ->
    console.log "#{ 'viff'.greyColor } #{ 'create'.info } #{ ' file '.prompt } #{filePath}"