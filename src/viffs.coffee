_ = require 'underscore'

Viff = require './viff.js'
processArgs = require './process.argv.js'
consoleStatus = require './console.status.js'
imgGen = require './image.generator'
resemble = require './resemble'
partialCanvas = require './canvas.drawimage'

config = processArgs process.argv

return console.log config if _.isString config

count = 3

cases = Viff.constructCases config.browsers, config.envHosts, config.paths
testGroups = Viff.split cases, count
resolvedCases = []

imgGen.reset();

for group in testGroups
  viff = new Viff config.seleniumHost
  viff.on 'afterEach', (_case, duration) -> imgGen.generateByCase _case if duration != 0
  consoleStatus viff

  viff.run group, ([cases, endTime]) ->
    resolvedCases = resolvedCases.concat cases
    unless --count
      imgGen.generateReport resolvedCases
      resemble.exit()
      partialCanvas.exit()
