_ = require 'underscore'
path = require 'path'

isPureObject = (obj) -> Object.prototype.toString.call(obj) is '[object Object]'

parseBrowsers = (value) ->
  browsers = []
  for browser in value.split ','
    browser = browser.trim()
    browsers.push(browser) unless _.isEmpty browser

  browsers

parseEnvHosts = (value) ->
  envValues = value.split ','
  envHosts = {}
  for envHostStr in envValues
    unless _.isEmpty(envHostStr)
      [env, host]= envHostStr.trim().split '='
      envHosts[env] = host

  envHosts

parsePaths = (value) ->
  (p.trim() for p in value.split(',') when !_.isEmpty(p.trim()))

mergeAndValidateConfig = (seleniumHost, browsers, envHosts, paths, reportFormat, grep, config) ->
  c = _.extend {}, config

  for name, idx in ['seleniumHost', 'browsers', 'envHosts', 'paths', 'reportFormat', 'grep']
    c[name] = arguments[idx] || c[name]

  c.browsers = ['firefox'] if c.browsers is undefined or c.browsers.length == 0
  c.reportFormat = 'html' if c.reportFormat is undefined

  throw new Error('--selenium-host isn\'t set correctly') if c.seleniumHost is undefined
  throw new Error('-envs aren\'t set correctly.') if c.envHosts is undefined or _.keys(c.envHosts).length < 1
  throw new Error('-paths aren\'t set correctly.') if c.paths is undefined or c.paths.length is 0

  c

filterByGrep = (paths, grep) ->
  [ret, ps] = [[], paths || []]
  reg = new RegExp grep

  ps.forEach (p, idx) ->
    target = p if _.isString p
    target = _.first(p) if _.isArray p
    target = _.first(_.keys(p)) if isPureObject p

    ret.push(p) if reg.test target

  ret

checkIfNeedHelp = (args) ->
  return false if isPureObject args

  argsCollection = ['-browsers', '-envs', '-paths', '--report-format', '--selenium-host']
  needHelp = true
  for param in args
    if argsCollection.indexOf(param) >= 0 || param.indexOf('.config.js') > 0
      needHelp = false
      break

  needHelp

help = ->
  version = require('../package.json').version
  """
  Version: #{version}

  Usage: viff /path/to/config_file.config.js

  Read More: https://github.com/winsonwq/viff

  """

processArgv = (args) ->
  if checkIfNeedHelp(args)
    return help()

  if isPureObject args
    config = args
  else
    while arg = args.shift()
      switch arg
        when '-browsers'
          browsers = parseBrowsers args.shift()

        when '-envs'
          envHosts = parseEnvHosts args.shift()
        when '-paths'
          paths = parsePaths args.shift()

        when '--report-format'
          reportFormat = args.shift().trim()

        when '--selenium-host'
          seleniumHost = args.shift().trim()

        when '-grep'
          grep = args.shift().trim()

        else
          if arg.indexOf('.config.js') > 0
            config = require path.resolve process.cwd(), arg

  c = mergeAndValidateConfig seleniumHost, browsers, envHosts, paths, reportFormat, grep, config
  c.paths = filterByGrep(c.paths, grep) if grep
  c

module.exports = processArgv
