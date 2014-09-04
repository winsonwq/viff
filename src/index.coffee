_ = require 'underscore'

Viff = require './viff.js'
processArgs = require './process.argv.js'
consoleStatus = require './console.status.js'
imgGen = require './image.generator'
resemble = require './resemble'
partialCanvas = require './canvas.drawimage'

config = processArgs process.argv

return console.log config if _.isString config

count = config.maxInstance ? 1

cases = Viff.constructCases config.browsers, config.envHosts, config.paths
testGroups = Viff.split cases, count
resolvedCases = []
exceptions = []

# imgGen.reset()
consoleStatus.logBefore()

for group in testGroups
  viff = new Viff config.seleniumHost

  viff.on 'afterEach', (_case, duration, fex, tex) ->
    consoleStatus.logAfterEach _case, duration, fex, tex, exceptions

  viff
  .run group
  .done ([cases, duration]) ->
    resolvedCases = resolvedCases.concat cases
    unless --count
      imgGen.generateReport resolvedCases
      resemble.exit()
      partialCanvas.exit()
      consoleStatus.logAfter resolvedCases, duration, exceptions
