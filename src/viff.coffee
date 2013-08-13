mr = require 'Mr.Async'
_ = require 'underscore'
Canvas = require 'canvas'

webdriver = require 'selenium-webdriver'
Comparison = require './comparison'

webdriver.promise.controlFlow().on 'uncaughtException', (e) -> 
  console.error 'Unhandled error: ' + e

class Viff
  constructor: (seleniumHost) ->
    @builder = new webdriver.Builder().usingServer(seleniumHost)
    @drivers = {}

  takeScreenshot: (browserName, envHost, url, callback) -> 
    that = @
    defer = mr.Deferred()
    defer.done(callback)
    
    unless driver = @drivers[browserName]
      @builder = @builder.withCapabilities { browserName: browserName }
      driver = @builder.build()
      @drivers[browserName] = driver

    envName = _.first(envName for envName of envHost)
    [url, selector, preHandle] = Viff.parseUrl url

    driver.get envHost[envName] + url
    preHandle driver, webdriver if _.isFunction preHandle
    driver.takeScreenshot().then (base64Img) -> 
      if _.isString selector
        Viff.dealWithPartial base64Img, driver, selector, (partialBase64Img) ->
          defer.resolve partialBase64Img
      else 
        defer.resolve base64Img

    defer.promise()

  takeScreenshots: (browsers, envHosts, links, callback) ->
    defer = mr.Deferred()
    defer.done callback

    compares = {}
    returned = 0
    total = browsers.length * links.length
    that = this

    _.each browsers, (browser) ->
      compares[browser] = compares[browser] || {}
      
      _.each links, (url) ->
        path = Viff.getPathKey url
        envCompares = {}

        _.each envHosts, (host, env) ->
          envHost = {}
          envHost[env] = host
          
          that.takeScreenshot browser, envHost, url, (base64Img) ->
            envHost[env] = base64Img
            _.extend(envCompares, envHost)

            if _.isEqual _.keys(envCompares), _.keys(envHosts)
              compares[browser][path] = new Comparison(envCompares)
              returned++

            if _.isEqual links.length, _.keys(compares[browser]).length
              that.drivers[browser].close()

            if returned == total
              defer.resolve compares
          
    defer.promise()

  @getPathKey: (url) ->
    [path, selector, preHandle] = Viff.parseUrl url
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
    url = urlInfo
    if _.isArray(urlInfo)
      url = _.first urlInfo 
      preHandle = _.last urlInfo if _.isFunction _.last(urlInfo)
      selector = urlInfo[1] if _.isString urlInfo[1]

    [url, selector, preHandle]

module.exports = Viff