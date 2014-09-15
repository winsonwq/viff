_ = require 'underscore'
util = require 'util'
{EventEmitter} = require 'events'

Q = require 'q'
Promise = require 'bluebird'
async = require 'async'
wd = require 'wd'
Comparison = require './comparison'
Testcase = require './testcase'
Capability = require './capability'
partialCanvas = require './canvas.drawimage'
dataUrlHelper = require './image.dataurl.helper'
imgGen = require './image.generator'
gm = require 'gm'

class Viff extends EventEmitter
  constructor: (seleniumHost) ->
    EventEmitter.call @

    @builder = wd.promiseChainRemote seleniumHost
    @drivers = {}

  takeScreenshot: (capability, host, url, callback) ->
    that = @
    new Promise (resolve, reject) ->
      capability = new Capability capability
      unless driver = that.drivers[capability.key()]
        that.drivers[capability.key()] = driver = that.builder.init capability

      [parsedUrl, selector, preHandle] = Testcase.parseUrl url

      driver.get(host + parsedUrl).then ->
        new Promise (res, rej) ->
          if _.isFunction preHandle
            preHandle driver, wd
            .then (err) -> 
              if err then rej() else res()
          else
            res()
        .then ->
          driver.takeScreenshot((err, base64Img) ->
            if _.isString selector
              Viff.dealWithPartial(base64Img, driver, selector, resolve, reject)
            else
              resolve new Buffer(base64Img, 'base64')
            )
            .catch reject

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

  @split: (cases, count) ->
    groups = []
    groups.push [] while count--
    groups[idx % groups.length].push _case for idx, _case of cases

    groups

  runAfterCase: (_case, duration, fex, tex) ->
    @emit 'afterEach', _case, duration, fex, tex
    if duration != 0 then imgGen.generateByCase _case else imgGen.generateFailedCase _case

  run: (cases, callback) ->
    that = @
    new Promise (resolve, reject) ->
      if callback
        @finally callback

      that.emit 'before', cases
      start = Date.now()

      Promise
      .map cases, (_case) ->
        new Promise (res, rej) ->
          startcase = Date.now()
          that.emit 'beforeEach', _case, 0
          that
          .takeScreenshot _case.from.capability, _case.from.host, _case.url
          .then (fs) ->
            if !fs
              that
              .runAfterCase _case, 0
              .then rej
            else
              that
              .takeScreenshot _case.to.capability, _case.to.host, _case.url
              .then (ts) ->
                if !ts
                  that
                  .runAfterCase _case, 0
                  .then rej
                else
                  Viff.runCase(_case, fs, ts).then (c) ->
                    that
                    .runAfterCase _case, Date.now() - startcase
                    .then res
      .finally ->
        endTime = Date.now() - start
        that.emit 'after', cases, endTime
        resolve [cases, endTime]
        that.closeDrivers()

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

  @dealWithPartial: (base64Img, driver, selector, resolve, reject) ->
    if !driver.elementByCss
      reject()
      return driver
    driver.elementByCss(selector)
      .then((elem) ->
        Promise.all([elem.getLocation(), elem.getSize()]).then ([location, size]) ->
          new Promise (res, rej) ->
            try
              cvs = partialCanvas.get()
              cvs.drawImage dataUrlHelper.toDataURL(base64Img), location, size, (data) ->
                res new Buffer(dataUrlHelper.toData(data), 'base64')
            catch e
              rej()
      )
      .then resolve

module.exports = Viff
