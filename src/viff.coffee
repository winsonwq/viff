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

  takeScreenshot: (browserName, envHost, url, callback) -> 

    that = @
    defer = mr.Deferred().done(callback)
    
    unless driver = @drivers[browserName]
      @builder = @builder.withCapabilities { browserName: browserName }
      driver = @builder.build()
      @drivers[browserName] = driver

    envName = _.first(envName for envName of envHost)
    [parsedUrl, selector, preHandle] = Viff.parseUrl url

    driver.get envHost[envName] + parsedUrl
    preHandle driver, webdriver if _.isFunction preHandle

    driver.call( ->
      driver.takeScreenshot().then (base64Img) -> 
        if _.isString selector
          Viff.dealWithPartial base64Img, driver, selector, (partialBase64Img) ->
            defer.resolve partialBase64Img, null
        else 
          defer.resolve base64Img, null

      return
    ).addErrback (ex) ->
      console.error "ERROR: For path #{url} with selector #{selector||''}, #{ex.message.split('\n')[0]}"
      defer.resolve ''

    defer.promise()

  constructCases: (browsers, envHosts, links) ->
    cases = []
    _.each browsers, (browser) ->
      _.each links, (url) ->
        [[from, envFromPath], [to, envToPath]] = _.pairs envHosts

        cases.push 
          browser: browser
          url: url
          fromname: from
          toname: to
          from: _.object [[from, envFromPath]]
          to: _.object [[to, envToPath]]

    cases

  takeScreenshots: (browsers, envHosts, links, callback) ->
    defer = mr.Deferred().done callback
    cases = @constructCases browsers, envHosts, links
    that = this
    compares = {}

    that.emit 'before', cases
    start = Date.now()
    mr.asynEach(cases, (_case) ->
      iterator = this

      path = Viff.getPathKey _case.url
      startcase = Date.now()
      compares[_case.browser] = compares[_case.browser] || {}

      that.takeScreenshot _case.browser, _case.from, _case.url, (fromImage, fromImgEx) ->
        that.takeScreenshot _case.browser, _case.to, _case.url, (toImage, toImgEx) ->

          if fromImgEx isnt null or toImgEx isnt null
            compares[_case.browser][path] = _case.result = null
            that.emit 'afterEach', _case, 0
            iterator.next()
          else 
            imgWithEnvs = _.object [[_case.fromname, fromImage], [_case.toname, toImage]]
            comparison = new Comparison imgWithEnvs
            
            comparison.diff (diffImg) ->
              compares[_case.browser][path] = _case.result = comparison
              that.drivers[_case.browser].quit() if links.length == _.keys(compares[_case.browser]).length
              that.emit 'afterEach', _case, Date.now() - startcase

            iterator.next()
    , -> 
      that.emit 'after', cases, Date.now() - start
      defer.resolve compares
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

          defer.resolve cvs.toBuffer().toString('base64')

    defer.promise()

  @diff: (compares, callback) ->
    defer = mr.Deferred().done callback

    comparisons = Viff.comparisons(compares)
    returned = 0
    _.each comparisons, (comparison) ->
      comparison.diff (diffImgBase64) ->
        defer.resolve(compares) if returned++ == comparisons.length - 1

    defer.promise()

  @comparisons: (compares) ->
    ret = []
    _.each compares, (urls, browserName) -> 
      _.each urls, (comparison, url) ->
        ret.push comparison

    ret

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