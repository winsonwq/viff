handlebars = require 'handlebars'
template = require('./html.report.template.js')

render = handlebars.compile template

reporter = 
  generate: (format, data) ->
    return render { compares: data } if format is 'html'
    return JSON.stringify(data) if format is 'json'

module.exports = reporter