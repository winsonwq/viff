Viff = require './viff.js'
reporter = require './reporter.js'
processArgs = require './process.argv.js'

config = processArgs process.argv

viff = new Viff('http://localhost:4444/wd/hub')
viff.takeScreenshots(config.browsers, config.envHosts, config.paths).done (compares)->
  Viff.diff(compares).done (compares) ->
    console.log reporter.generate config.reportFormat, compares


