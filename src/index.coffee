_ = require 'underscore'
require 'webdriver-helper'

Viff = require './viff.js'
Reporter = require './reporter.js'
processArgs = require './process.argv.js'
consoleStatus = require './console.status.js'

config = processArgs process.argv

return console.log config if _.isString config

viff = new Viff config.seleniumHost

viff.takeScreenshots(config.browsers, config.envHosts, config.paths).done (compares)->
  Viff.diff compares, (compares) ->
    console.log new Reporter(compares).to config.reportFormat

consoleStatus viff
