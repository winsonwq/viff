_ = require 'underscore'

Viff = require './viff.js'
processArgs = require './process.argv.js'
consoleStatus = require './console.status.js'
imgGen = require './image.generator'
_eval = require './node.eval'
resemble = require './resemble'
partialCanvas = require './canvas.drawimage'

app = (config) ->
  return console.log config if _.isString config

  viff = new Viff config.seleniumHost

  if config.reportFormat == 'file'
    consoleStatus viff

    # clean the images and report.json
    viff.on 'before', (cases) ->  imgGen.reset();

    # generate images by each case
    viff.on 'afterEach', (_case, duration) -> imgGen.generateByCase _case if duration != 0

    # generate report.json
    viff.on 'after', (cases, duration) ->
      imgGen.generateReport cases
      resemble.exit()
      partialCanvas.exit()

  cases = Viff.constructCases config.browsers, config.envHosts, config.paths
  viff.run cases

process.stdin.on 'readable', ->
  if null != (configstr = process.stdin.read())
    app processArgs _eval configstr
