mr = require 'Mr.Async'
_ = require 'underscore'
Canvas = require 'canvas'
util = require 'util'
EventEmitter = require('events').EventEmitter

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
    defer = mr.Deferred()
    
    defer.done (base64Img, duration) => @emit 'tookScreenshot', browserName, envHost, url, duration, base64Img
    defer.done(callback)
    
    unless driver = @drivers[browserName]
      @builder = @builder.withCapabilities { browserName: browserName }
      driver = @builder.build()
      @drivers[browserName] = driver

    envName = _.first(envName for envName of envHost)
    [parsedUrl, selector, preHandle] = Viff.parseUrl url

    driver.get envHost[envName] + parsedUrl
    preHandle driver, webdriver if _.isFunction preHandle

    driver.call( ->
      startDate = Date.now()
      driver.takeScreenshot().then (base64Img) -> 
        if _.isString selector
          Viff.dealWithPartial base64Img, driver, selector, (partialBase64Img) ->
            defer.resolve partialBase64Img, Date.now() - startDate
        else 
          defer.resolve base64Img, Date.now() - startDate

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

  caseShot: (_case) ->
    fromDefer = @takeScreenshot _case.browser, _case.from, _case.url
    toDefer = @takeScreenshot _case.browser, _case.to, _case.url

    [fromDefer, toDefer]

  takeScreenshots: (browsers, envHosts, links, callback) ->
    defer = mr.Deferred().done callback
    cases = @constructCases browsers, envHosts, links
    that = this
    compares = {}

    mr.asynEach(cases, (c) ->
      iterator = this

      path = Viff.getPathKey c.url
      compares[c.browser] = compares[c.browser] || {}

      mr.when(that.caseShot(c)).then (fromImage, fromDuration, toImage, toDuration) ->
        imgWithEnvs = _.object [[c.fromname, fromImage], [c.toname, toImage]]
        compares[c.browser][path] = new Comparison imgWithEnvs

        that.drivers[c.browser].quit() if links.length == _.keys(compares[c.browser]).length

        iterator.next()

    , -> defer.resolve compares).start()

    defer.promise()

  @getPathKey: (url) ->
    [path, selector, preHandle, description] = Viff.parseUrl url
    if _.isString description
      path = description
    else if _.isString selector
      path = "#{path} (#{selector})" if _.isString selector
    path

  @dealWithPartial: (base64Img, driver, selector, callback) ->
    defer = mr.Deferred()
    defer.done callback

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
    defer = mr.Deferred()
    defer.done callback

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