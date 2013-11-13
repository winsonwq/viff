_ = require 'underscore'
require 'webdriver-helper'

Viff = require './viff.js'
Reporter = require './reporter.js'
processArgs = require './process.argv.js'
consoleStatus = require './console.status.js'
imgGen = require './image.generator.js'

config = processArgs process.argv

return console.log config if _.isString config

viff = new Viff config.seleniumHost

viff.takeScreenshots(config.browsers, config.envHosts, config.paths);

consoleStatus viff

if config.reportFormat == 'file'
  
  imgGen.on imgGen.CREATE_FOLDER, (folerPath) ->
    console.log "#{ 'viff'.greyColor } #{ 'create'.info } #{ 'folder'.prompt } #{folerPath}"

  imgGen.on imgGen.CREATE_FILE, (filePath) ->
    console.log "#{ 'viff'.greyColor } #{ 'create'.info } #{ ' file '.prompt } #{filePath}"
  
  # clean the images and report.json
  viff.on 'before', (cases) -> imgGen.reset()

  # generate images by each case
  viff.on 'afterEach', (c, duration) -> imgGen.generateByCase c

  # generate report.json  
  viff.on 'after', (cases, duration) -> 
    imgGen.generateReport cases

