_ = require 'underscore'

class Testcase

  constructor: (@browser, browserFrom, browserTo, hostFrom, hostTo, nameFrom, nameTo, @url) ->
    @from = 
      browser: browserFrom
      name: nameFrom
      host: hostFrom
    @to = 
      browser: browserTo
      name: nameTo
      host: hostTo

  @parseUrl: (urlInfo) ->
    if Object.prototype.toString.call(urlInfo) is '[object Object]'
      description = _.first _.keys urlInfo
      urlInfo = urlInfo[description]

    if _.isArray urlInfo
      url = _.first urlInfo 
      preHandle = _.last urlInfo if _.isFunction _.last(urlInfo)
      selector = urlInfo[1] if _.isString urlInfo[1]
    else if _.isString urlInfo
      url = urlInfo

    [url, selector, preHandle, description]

  @getPathKey: (url) ->
    [path, selector, preHandle, description] = Testcase.parseUrl url
    if _.isString description
      path = description
    else if _.isString selector
      path = "#{path} (#{selector})" if _.isString selector
    path

  pathKey: -> Testcase.getPathKey @url

  key: ->
    path = @pathKey()
    if @from.name is @to.name
      path = @from.name + ':' + path

    path


module.exports = Testcase