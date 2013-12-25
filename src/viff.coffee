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
      console.error "ERROR: For path #{util.inspect(url)} with selector #{selector||''}, #{ex.message.split('\n')[0]}"
      defer.resolve ''

    defer.promise()

  @constructCase: (browser, browserFrom, browserTo, hostFrom, hostTo, nameFrom, nameTo, url) ->
    browser: browser
    url: url
    from:
      browser: browserFrom
      name: nameFrom
      host: hostFrom
    to: 
      browser: browserTo
      name: nameTo
      host: hostTo

  @constructCases: (browsers, envHosts, links) ->
    cases = []
    _.each links, (url) ->
      _.each browsers, (browser) ->

        if _.contains(browser, '-')
          [browserFrom, browserTo] = browser.split '-'

          _.each envHosts, (host, envName) ->
            cases.push Viff.constructCase browser, browserFrom, browserTo, host, host, envName, envName, url
        else
          [[from, envFromHost], [to, envToHost]] = _.pairs envHosts
          cases.push Viff.constructCase browser, browser, browser, envFromHost, envToHost, from, to, url

    cases

  takeScreenshots: (browsers, envHosts, links, callback) ->
    defer = mr.Deferred().done callback
    cases = Viff.constructCases browsers, envHosts, links
    that = this

    @emit 'before', cases
    start = Date.now()
    mr.asynEach(cases, (_case) ->
      iterator = this

      startcase = Date.now()
      that.takeScreenshot _case.from.browser, _case.from.host, _case.url, (fromImage, fromImgEx) ->
        that.takeScreenshot _case.to.browser, _case.to.host, _case.url, (toImage, toImgEx) ->

          if fromImgEx isnt null or toImgEx isnt null
            that.emit 'afterEach', _case, 0
            iterator.next()
          else 
            imgWithEnvs = _.object [[_case.from.browser + '-' + _case.from.name, fromImage], [_case.to.browser + '-' + _case.to.name, toImage]]
            comparison = new Comparison imgWithEnvs
            
            comparison.diff (diffImg) ->
              _case.result = comparison
              that.emit 'afterEach', _case, Date.now() - startcase

              iterator.next()
    , -> 
      endTime = Date.now() - start
      that.closeDrivers()
      that.emit 'after', cases, endTime

      defer.resolve cases, endTime
    ).start()

    defer.promise()

  closeDrivers: () ->
    @drivers[browser].quit() for browser of @drivers

  @getPathKey: (url) ->
    [path, selector, preHandle, description] = Viff.parseUrl url
    if _.isString description
      path = description
    else if _.isString selector
      path = "#{path} (#{selector})" if _.isString selector
    path

  @getCaseKey: (_case) ->
    path = Viff.getPathKey _case.url
    if _case.from.name is _case.to.name
      path = _case.from.name + ':' + path

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