mr = require 'Mr.Async'
_ = require 'underscore'
webdriver = require 'selenium-webdriver'
Comparison = require './comparison'

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
    [url, preHandle] = url if _.isArray url

    driver.get envHost[envName] + url
    preHandle driver, webdriver if _.isFunction preHandle
    driver.takeScreenshot().then (base64Img) -> 
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
        url = _.first url if _.isFunction url[1]
        envCompares = {}

        _.each envHosts, (host, env) ->
          envHost = {}
          envHost[env] = host
          
          that.takeScreenshot browser, envHost, url, (base64Img) ->
            envHost[env] = base64Img
            _.extend(envCompares, envHost)

            if _.isEqual _.keys(envCompares), _.keys(envHosts)
              compares[browser][url] = new Comparison(envCompares)
              returned++

            if _.isEqual links.length, _.keys(compares[browser]).length
              that.drivers[browser].close()

            if returned == total
              defer.resolve compares
          
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

module.exports = Viff