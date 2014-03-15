_ = require 'underscore'
Canvas = require 'canvas'
util = require 'util'
{EventEmitter} = require 'events'

Q = require 'q'
async = require 'async'
wd = require 'wd'
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
    defer.promise.then callback

    capability = new Capability capability
    unless driver = @drivers[capability.key()]
      @drivers[capability.key()] = driver = @builder.init capability

    [parsedUrl, selector, preHandle] = Testcase.parseUrl url

    driver.get(host + parsedUrl).then ->

      if _.isFunction preHandle
        prepromise = Q.fcall () -> preHandle driver
      else
        prepromise = Q()

      prepromise.then ->
        driver.takeScreenshot((err, base64Img) -> 
          if _.isString selector
            Viff.dealWithPartial(base64Img, driver, selector, defer.resolve)
              .catch defer.reject
          else
            defer.resolve new Buffer(base64Img, 'base64')
          )
          .catch defer.reject

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

    async.eachSeries cases, (_case, next) -> 
      startcase = Date.now()
      that.emit 'beforeEach', _case, 0

      compareFrom = that.takeScreenshot _case.from.capability, _case.from.host, _case.url
      Q.allSettled([compareFrom]).then ([fs]) -> 

        compareTo = that.takeScreenshot _case.to.capability, _case.to.host, _case.url
        Q.allSettled([compareTo]).then ([ts]) ->

          if fs.reason or ts.reason
            that.emit 'afterEach', _case, 0, fs.reason, ts.reason
            next()
          else
            Viff.runCase(_case, fs.value, ts.value).then (c) ->
              that.emit 'afterEach', _case, Date.now() - startcase, fs.reason, ts.reason
              next()

    , (err) ->
      endTime = Date.now() - start
      that.emit 'after', cases, endTime
      defer.resolve [cases, endTime]

      that.closeDrivers()

    defer.promise

  @runCase: (_case, fromImage, toImage, callback) ->
    imgWithEnvs = _.object [[_case.from.capability.key() + '-' + _case.from.name, fromImage], [_case.to.capability.key() + '-' + _case.to.name, toImage]]
    comparison = new Comparison imgWithEnvs
    
    diff = comparison.diff (diffImg) -> 
      _case.result = comparison
      _case

    callback && diff.then callback
    
    diff

  closeDrivers: () ->
    @drivers[browser].quit() for browser of @drivers

  @dealWithPartial: (base64Img, driver, selector, callback) ->
    driver.elementByCss(selector)
      .then((elem) ->
        Q.all([elem.getLocation(), elem.getSize()]).then ([location, size]) ->
          cvs = new Canvas(size.width, size.height)
          ctx = cvs.getContext '2d'
          img = new Canvas.Image
          img.src = new Buffer base64Img, 'base64'
          ctx.drawImage img, location.x, location.y, size.width, size.height, 0, 0, size.width, size.height
          cvs.toBuffer()
      )
      .then callback

module.exports = Viff