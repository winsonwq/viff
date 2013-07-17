_ = require 'underscore'

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
  _.select value.split(','), (path) -> !_.isEmpty(path.trim())

mergeAndValidateConfig = (seleniumHost, browsers, envHosts, paths, reportFormat, config) ->
  config = _.extend config || {}, {
    seleniumHost: seleniumHost,
    browsers: browsers,
    envHosts: envHosts,
    paths: paths,
    reportFormat: reportFormat
  }

  config.browsers = ['firefox'] if config.browsers is undefined or config.browsers.length == 0
  config.reportFormat = 'html' if reportFormat is undefined

  throw new Error('--selenium-host isn\'t set correctly') if config.seleniumHost is undefined
  throw new Error('-envs aren\'t set correctly.') if config.envHosts is undefined or _.keys(config.envHosts).length < 2
  throw new Error('-paths aren\'t set correctly.') if config.paths is undefined or config.paths.length is 0

  config

processArgv = (args) ->
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

      else
        if arg.indexOf('.config.js') > 0
          config = require arg

  mergeAndValidateConfig seleniumHost, browsers, envHosts, paths, reportFormat, config

module.exports = processArgv