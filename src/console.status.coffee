require './color.helper.js'
imgGen = require './image.generator.js'
Viff = require './viff'

durationFormat = (duration) -> (duration / 1000).toFixed(2) + 's'

module.exports = (viff) ->

  exceptions = []

  # clean the images and report.json
  viff.on 'before', (cases) -> console.log 'Viff is taking screenshots...\n'

  viff.on 'afterEach', (_case, duration, fex, tex) ->
    if fex or tex
      exceptions.push { fex: fex, tex: tex, key: _case.key() }
      console.log "  #{(exceptions.length + ')').error} #{_case.browser.error} #{_case.key().error} "
    else 
      drationStr = "(#{durationFormat(duration)})".greyColor
      console.log "  - #{_case.browser.info} #{_case.key().greyColor} #{drationStr}"

  # generate report.json  
  viff.on 'after', (cases, duration) -> 
    console.log "\nDone in #{durationFormat(duration)}, #{(exceptions.length + ' failed.').greyColor}\n"

    if total = exceptions.length
      while ex = exceptions.shift()
        fexMsg = ex.fex.message + '\n\n' if ex.fex?.message?
        texMsg = ex.tex.message + '\n\n' if ex.tex?.message? 
        title = (total - exceptions.length) + ') ' + ex.key + '\n'
        message = "    #{title}#{fexMsg.error}#{texMsg.error}".replace(/\n/g, '\n       ')
        console.error message

      console.error ''
      process.exit 1