mr = require 'Mr.Async'
_ = require 'underscore'
Canvas = require 'canvas'
util = require 'util'
{EventEmitter} = require 'events'

webdriver = require 'selenium-webdriver'
Comparison = require './comparison'

webdriver.promise.controlFlow().on 'uncaughtException', (e) -> 
  console.error 'Unhandled error: ' + e

class Viff extends EventEmitter
  constructor: (seleniumHost) ->
    EventEmitter.call @

    @builder = new webdriver.Builder().usingServer(seleniumHost)
    @drivers = {}

  takeScreenshot: (browserName, host, url, callback) -> 

    that = @
    defer = mr.Deferred().done(callback)
    
    unless driver = @drivers[browserName]
      @builder = @builder.withCapabilities { browserName: browserName }
      driver = @builder.build()
      @drivers[browserName] = driver

    [parsedUrl, selector, preHandle] = Viff.parseUrl url

    driver.get host + parsedUrl
    preHandle driver, webdriver if _.isFunction preHandle

    driver.call( ->
      driver.takeScreenshot().then (base64Img) -> 
        if _.isString selector
          Viff.dealWithPartial base64Img, driver, selector, (partialImgBuffer) ->
            defer.resolve partialImgBuffer, null
        else 
          defer.resolve new Buffer(base64Img, 'base64'), null

      return
    ).addErrback (ex) ->
      console.error "ERROR: For path #{url} with selector #{selector||''}, #{ex.message.split('\n')[0]}"
      defer.resolve ''

    defer.promise()

  constructCases: (browsers, envHosts, links) ->
    cases = []
    _.each browsers, (browser) ->
      _.each links, (url) ->
        [[from, envFromHost], [to, envToHost]] = _.pairs envHosts

        cases.push 
          browser: browser
          url: url
          from: 
            name: from
            host: envFromHost
          to: 
            name: to
            host: envToHost

    cases

  takeScreenshots: (browsers, envHosts, links, callback) ->
    defer = mr.Deferred().done callback
    cases = @constructCases browsers, envHosts, links
    that = this

    @emit 'before', cases
    start = Date.now()
    mr.asynEach(cases, (_case) ->
      iterator = this

      path = Viff.getPathKey _case.url
      startcase = Date.now()

      that.takeScreenshot _case.browser, _case.from.host, _case.url, (fromImage, fromImgEx) ->
        that.takeScreenshot _case.browser, _case.to.host, _case.url, (toImage, toImgEx) ->

          if fromImgEx isnt null or toImgEx isnt null
            that.emit 'afterEach', _case, 0
            iterator.next()
          else 
            imgWithEnvs = _.object [[_case.from.name, fromImage], [_case.to.name, toImage]]
            comparison = new Comparison imgWithEnvs
            
            comparison.diff (diffImg) ->
              _case.result = comparison
              that.emit 'afterEach', _case, Date.now() - startcase

              iterator.next()
    , -> 
      endTime = Date.now() - start
      that.drivers[browser].quit() for browser in browsers
      that.emit 'after', cases, endTime

      defer.resolve cases, endTime
    ).start()

    defer.promise()

  @getPathKey: (url) ->
    [path, selector, preHandle, description] = Viff.parseUrl url
    if _.isString description
      path = description
    else if _.isString selector
      path = "#{path} (#{selector})" if _.isString selector
    path

  @dealWithPartial: (base64Img, driver, selector, callback) ->
    defer = mr.Deferred().done callback

    driver.findElement(webdriver.By.css(selector)).then (elem) ->
      elem.getLocation().then (location) ->
        elem.getSize().then (size) ->
          cvs = new Canvas(size.width, size.height)
          ctx = cvs.getContext '2d'
          img = new Canvas.Image
          img.src = new Buffer base64Img, 'base64'
          ctx.drawImage img, location.x, location.y, size.width, size.height, 0, 0, size.width, size.height

          defer.resolve cvs.toBuffer()

    defer.promise()

  @parseUrl = (urlInfo) ->
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

module.exports = Viff