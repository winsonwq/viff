_ = require 'underscore'
Canvas = require 'canvas'
util = require 'util'
{EventEmitter} = require 'events'

Q = require 'q'
wd = require 'wd'
webdriver = require 'selenium-webdriver'
Comparison = require './comparison'
Testcase = require './testcase'
Capability = require './capability'

class Viff extends EventEmitter
  constructor: (seleniumHost) ->
    EventEmitter.call @

    @builder = wd.promiseChainRemote seleniumHost
    @drivers = {}

  takeScreenshot: (capability, host, url, callback) -> 
    that = @
    defer = Q.defer()
    defer.promise.done callback

    capability = new Capability capability

    unless driver = @drivers[capability.key()]
      @drivers[capability.key()] = driver = @builder.init capability

    [parsedUrl, selector, preHandle] = Testcase.parseUrl url

    driver.get host + parsedUrl
    preHandle driver if _.isFunction preHandle

    driver.takeScreenshot (err, base64Img) -> 
      return defer.resolve ['', ex] if err

      if _.isString selector
        Viff.dealWithPartial base64Img, driver, selector, (err, partialImgBuffer) ->
          defer.resolve ['', err] if err
          defer.resolve [partialImgBuffer, null]
      else
        defer.resolve [new Buffer(base64Img, 'base64'), null]

    defer.promise

  @constructCases: (capabilities, envHosts, links) ->
    cases = []
    _.each links, (url) ->
      _.each capabilities, (capability) ->

        if _.isArray capability
          [capabilityFrom, capabilityTo] = capability

          _.each envHosts, (host, envName) ->
            cases.push new Testcase(capabilityFrom, capabilityTo, host, host, envName, envName, url)
        else
          [[from, envFromHost], [to, envToHost]] = _.pairs envHosts
          cases.push new Testcase(capability, capability, envFromHost, envToHost, from, to, url)

    cases

  run: (cases, callback) ->
    defer = Q.defer()
    defer.promise.done callback
    that = this

    @emit 'before', cases
    start = Date.now()

    endQueue = (index) ->
      if index == cases.length - 1
        endTime = Date.now() - start
        
        that.emit 'after', cases, endTime
        defer.resolve [cases, endTime]

        that.closeDrivers()

    cases.reduce (soFar, _case, index) -> 
      startcase = Date.now()
      that.emit 'beforeEach', _case, 0

      compareFrom = that.takeScreenshot _case.from.capability, _case.from.host, _case.url
      compareTo = that.takeScreenshot _case.to.capability, _case.to.host, _case.url

      next = Q.spread [compareFrom, compareTo], ([fromImage, fromImgEx], [toImage, toImgEx]) ->
        if fromImgEx isnt null or toImgEx isnt null
          that.emit 'afterEach', _case, 0, fromImgEx, toImgEx
          endQueue index
        else 
          imgWithEnvs = _.object [[_case.from.capability.key() + '-' + _case.from.name, fromImage], [_case.to.capability.key() + '-' + _case.to.name, toImage]]
          comparison = new Comparison imgWithEnvs
          
          comparison.diff (diffImg) ->
            _case.result = comparison
            that.emit 'afterEach', _case, Date.now() - startcase
            endQueue index

      soFar.then next
    , Q()

    defer.promise

  closeDrivers: () ->
    @drivers[browser].quit() for browser of @drivers

  @dealWithPartial: (base64Img, driver, selector, callback) ->
    defer = Q.defer()
    defer.promise.done callback

    driver.elementByCss selector, (err, elem) ->
      defer.resolve err, null if err

      elem && elem.getLocation (err, location) ->
        elem.getSize (err, size) ->
          cvs = new Canvas(size.width, size.height)
          ctx = cvs.getContext '2d'
          img = new Canvas.Image
          img.src = new Buffer base64Img, 'base64'
          ctx.drawImage img, location.x, location.y, size.width, size.height, 0, 0, size.width, size.height

          defer.resolve [null, cvs.toBuffer()]
          
    defer.promise

module.exports = Viff