_ = require 'underscore'
handlebars = require 'handlebars'
colors = require 'colors'
template = require './html.report.template.js'
ImageGenerator = require './image.generator.js'

render = handlebars.compile template

colors.setTheme 
  info: 'green'
  prompt: 'magenta'
  greyColor: 'grey'

class Reporter
  constructor: (@compares) ->
    @cases = []
    @differences = []
    @totalAnalysisTime = 0

    for browser, urls of @compares
      for url, diff of urls
        diffCase = {}
        diffCase[url] = diff

        @cases.push diffCase
        @differences.push(diffCase) if diff.misMatchPercentage isnt 0
        @totalAnalysisTime += diff.analysisTime

    @caseCount = @cases.length
    @diffCount = @differences.length

  to: (format = 'html') ->
    reportObj = 
      compares: @compares
      caseCount: @caseCount
      sameCount: @caseCount - @diffCount
      diffCount: @diffCount
      totalAnalysisTime: @totalAnalysisTime 

    return render reportObj if format is 'html'
    return JSON.stringify(reportObj) if format is 'json'

    if format is 'file'
      ImageGenerator.on ImageGenerator.CREATE_FOLDER, (folerPath) ->
        console.log "#{ 'viff'.greyColor } #{ 'create'.info } #{ 'folder'.prompt } #{folerPath}"

      ImageGenerator.on ImageGenerator.CREATE_FILE, (filePath) ->
        console.log "#{ 'viff'.greyColor } #{ 'create'.info } #{ ' file '.prompt } #{filePath}"

      ImageGenerator.generate reportObj
      return ''


module.exports = Reporter