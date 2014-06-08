_ = require 'underscore'

Viff = require './viff.js'
processArgs = require './process.argv.js'
consoleStatus = require './console.status.js'
imgGen = require './image.generator'
resemble = require './resemble'
partialCanvas = require './canvas.drawimage'

config = processArgs process.argv

return console.log config if _.isString config

viff = new Viff config.seleniumHost
exceptions = []

# clean the images and report.json
viff.on 'before', (cases) ->
  imgGen.reset()
  consoleStatus.logBefore()

# generate images by each case
viff.on 'afterEach', (_case, duration, fex, tex) ->
  imgGen.generateByCase _case if duration != 0
  consoleStatus.logAfterEach _case, duration, fex, tex, exceptions

# generate report.json
viff.on 'after', (cases, duration) ->
  imgGen.generateReport cases
  resemble.exit()
  partialCanvas.exit()
  consoleStatus.logAfter cases, duration, exceptions

cases = Viff.constructCases config.browsers, config.envHosts, config.paths
viff.run cases
